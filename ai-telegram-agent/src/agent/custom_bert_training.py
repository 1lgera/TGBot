import json
import os
import re
import time
import traceback
import numpy as np
import torch
import pandas as pd
import gc
import transformers
from joblib import Parallel, delayed
from torch.utils.data import DataLoader, Dataset
from transformers import PreTrainedTokenizerFast
from pathlib import Path
import sys
sys.path.append("../..")
from src.config.config import config


class BERTClass(torch.nn.Module):
    def __init__(self):
        super(BERTClass, self).__init__()
        self.l1 = transformers.BertModel.from_pretrained('bert-base-uncased')
        self.l2 = torch.nn.Dropout(0.01)
        self.l3 = torch.nn.Linear(768, 20)

    def forward(self, ids, mask, token_type_ids):
        _, output_1 = self.l1(ids, attention_mask=mask, token_type_ids=token_type_ids, return_dict=False)
        output_2 = self.l2(output_1)
        output = self.l3(output_2)
        return output


class CustomDataset(Dataset):

    def __init__(self, dataframe, tokenizer, max_len):
        self.tokenizer = tokenizer
        self.data = dataframe
        self.title = dataframe['Message']
        self.targets = self.data.target_list
        self.max_len = max_len

    def __len__(self):
        return len(self.title)

    def __getitem__(self, index):
        title = str(self.title[index])
        title = " ".join(title.split())

        inputs = self.tokenizer.encode_plus(
            title,
            None,
            add_special_tokens=True,
            max_length=self.max_len,
            padding='max_length',
            return_token_type_ids=True,
            truncation=True
        )
        ids = inputs['input_ids']
        mask = inputs['attention_mask']
        token_type_ids = inputs["token_type_ids"]

        return {
            'ids': torch.tensor(ids, dtype=torch.long),
            'mask': torch.tensor(mask, dtype=torch.long),
            'token_type_ids': torch.tensor(token_type_ids, dtype=torch.long),
            'targets': torch.tensor(self.targets[index], dtype=torch.float)
        }


def load_ckp(checkpoint_fpath, model, optimizer):
    try:
        checkpoint = torch.load(checkpoint_fpath, weights_only=True)
        model.load_state_dict(checkpoint)
    except:
        print(traceback.format_exc())


def save_ckp(state, checkpoint_path):
    torch.save(state.state_dict(), checkpoint_path)


def loss_fn(outputs, targets):
    return torch.nn.BCEWithLogitsLoss()(outputs, targets)


def print_bar(percent, loss, time_dif):
    percent = int(percent*100) + 1
    bar = "[" + "." * 100 + "]"
    pattern = "\\[" + "." * percent
    repl = "[" + "█" * percent
    bar = re.sub(pattern, repl, bar)
    sec = time_dif / percent * 100 - time_dif
    min = int(sec / 60)
    sec = int(sec % 60)
    print("\r", bar, percent, "%Complete\t", "Loss:", loss, "\tRemain time:", f'{min}:{sec}', end="")


# Device
os.environ["CUDA_VISIBLE_DEVICES"] = "0,1"
device = 'cuda:0' if torch.cuda.is_available() else 'cpu'
print('Device:', device)

df = pd.read_csv('./messages.csv', delimiter="|")
df = df[['Label', 'Message']]
df["Message"] = df["Message"].map(lambda label: re.sub("[^А-ЯЁA-Z ]", "", label.upper()))
print(df)

columns = np.unique(df[['Label']].values)
RESERVED_COLUMNS_NUMBER = len(columns)
print(len(columns))

with open("columns.json", "w", encoding="utf8") as file:
    file.write(json.dumps(list(columns), ensure_ascii=False))
    file.close()

MAX_LEN = config["agent"]["bert"]["training"]["MAX_LEN"]
# Должен быть 32
TRAIN_BATCH_SIZE = config["agent"]["bert"]["training"]["TRAIN_BATCH_SIZE"]
# Надо 200+
EPOCHS = config["agent"]["bert"]["training"]["EPOCHS"]
LEARNING_RATE = 1e-05
PART_SIZE = config["agent"]["bert"]["training"]["PORTION_SIZE"]
# Надо 1к
VALIDATION_SIZE = config["agent"]["bert"]["training"]["VALIDATION_SIZE"]

tokenizer = PreTrainedTokenizerFast(tokenizer_file="../../src/agent/tokenizer.json")
tokenizer.add_special_tokens({'pad_token': '[PAD]'})
model = BERTClass()
model.to(device)
optimizer = torch.optim.Adam(params=model.parameters(), lr=LEARNING_RATE)

load_ckp('../../src/agent/model/checkpoint.pt', model, optimizer)

train_params = {'batch_size': TRAIN_BATCH_SIZE,
                'shuffle': True,
                'num_workers': 0
                }
test_params = {'batch_size': TRAIN_BATCH_SIZE,
               'shuffle': False,
               'num_workers': 0
               }
checkpoint_path = './model/checkpoint.pt'
Path("./model").mkdir(parents=True, exist_ok=True)


def train_model(n_epochs, valid_loss_min_input, model,
                optimizer, checkpoint_path):
    print("START")
    for part in range(int(len(df) / PART_SIZE) + (1 if len(df) % PART_SIZE != 0 else 0)):
        print("STARTING TRAINING FROM", part * PART_SIZE, "TO", (part + 1) * PART_SIZE)
        df3 = df.drop(range(0, part * PART_SIZE), axis=0)
        df3 = df3.drop(range((part + 1) * PART_SIZE, len(df)), axis=0)
        df3 = df3.reset_index(drop=True)
        print("DATASET DROPPED")
        sparse_labels = pd.get_dummies(df3['Label'].explode()).groupby(level=0).sum()
        sparse_labels = sparse_labels.div(sparse_labels.sum(axis=1), axis=0)
        print("SPARSE MATRIX CREATED")
        start = time.time()
        df_zeros = []
        for column in columns:
            if not column in sparse_labels.columns:
                df_zeros.append(pd.DataFrame({column: [0.0] * len(sparse_labels)}))
        sparse_labels = pd.concat([sparse_labels, *df_zeros], axis=1)
        print("COLUMNS ADDED IN " + str(time.time() - start) + " S")
        sparse_labels = sparse_labels.reindex(sorted(sparse_labels.columns), axis=1)
        print(sparse_labels)
        df3 = df3.join(sparse_labels)
        del sparse_labels
        gc.collect()

        my_d = {}
        test_df = df3.drop(range(VALIDATION_SIZE, len(df3)), axis=0)
        test_df['target_list'] = test_df[test_df.columns[2:]].values.tolist()
        df3 = df3.drop(['Label'], axis=1)
        df3['target_list'] = df3[df3.columns[1:]].values.tolist()
        df3 = df3[['Message', 'target_list']].copy()
        for i in range(VALIDATION_SIZE):
            my_d[i] = test_df.iloc[i]['Label']
        test_set = CustomDataset(test_df, tokenizer, MAX_LEN)
        test_loader = DataLoader(test_set, **test_params)
        training_set = CustomDataset(df3, tokenizer, MAX_LEN)
        training_loader = DataLoader(training_set, **train_params)

        for epoch in range(0, n_epochs + 1):
            model.train()
            print('############# Epoch {}: Training Start   #############'.format(epoch))
            start = time.time()
            for batch_idx, data in enumerate(training_loader):
                ids = data['ids'].to(device, dtype=torch.long)
                mask = data['mask'].to(device, dtype=torch.long)
                token_type_ids = data['token_type_ids'].to(device, dtype=torch.long)
                targets = data['targets'].to(device, dtype=torch.float)
                outputs = model(ids, mask, token_type_ids)
                optimizer.zero_grad()
                loss = loss_fn(outputs, targets)

                if batch_idx % 2 == 0 or batch_idx == len(training_loader) - 1:
                    end = time.time()
                    print_bar(batch_idx / round(len(df3) / TRAIN_BATCH_SIZE), loss.item(), end - start)
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()
            print()
            print('############# Epoch {}: Training End     #############'.format(epoch))
            model.eval()
            print('############# Epoch {}: Validation Start     #############'.format(epoch))

            # Validation

            def do_prediction(loader):
                fin_outputs = []
                with torch.no_grad():
                    for _, data in enumerate(loader):
                        ids = data['ids'].to(device, dtype=torch.long)
                        mask = data['mask'].to(device, dtype=torch.long)
                        token_type_ids = data['token_type_ids'].to(device, dtype=torch.long)
                        outputs = model(ids, mask, token_type_ids)
                        fin_outputs.extend(torch.sigmoid(outputs).cpu().detach().numpy().tolist())
                return fin_outputs

            pred_outputs = do_prediction(test_loader)
            preds_df = pd.DataFrame(pred_outputs, columns=columns)

            def validate(line):
                dataline = preds_df.iloc[line]
                d = dataline[dataline != 0].to_dict()
                sorted_list = sorted(d.items(), key=lambda x: x[1], reverse=True)[:1]
                if my_d[dataline.name] == sorted_list[0][0]:
                    return 1, 1
                else:
                    return 0, 1

            results = Parallel(n_jobs=31)(delayed(validate)(line) for line in range(len(preds_df)))

            print('############# Epoch {}: Validation End     #############'.format(epoch))
            ins = 0
            size = 0
            for i in results:
                ins += i[0]
                size += i[1]
            acc = ins / size * 100
            print(ins, " ", size)
            print("Accuracy: ", acc)
            print('############# Epoch {}  Done   #############\n'.format(epoch))
            # save checkpoint
            print('Saving model ...')
            save_ckp(model, checkpoint_path)
        del df3
        del test_df
        del test_set
        del test_loader
        del training_set
        del training_loader
        del my_d
        gc.collect()
    return model


trained_model = train_model(EPOCHS, np.inf, model, optimizer, checkpoint_path)