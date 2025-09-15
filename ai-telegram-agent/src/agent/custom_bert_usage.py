import json
import os
import re
import traceback
import torch
import pandas as pd
import numpy as np
import transformers
from torch.utils.data import DataLoader, Dataset
from transformers import PreTrainedTokenizerFast
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay, roc_curve, roc_auc_score
import matplotlib.pyplot as plt
import seaborn as sn
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
        }


def load_ckp(checkpoint_fpath, model, optimizer):
    try:
        checkpoint = torch.load(
            checkpoint_fpath,
            map_location=torch.device('cpu'),
            weights_only=True
        )
        model.load_state_dict(checkpoint)
    except:
        print(traceback.format_exc())


# Device
os.environ["CUDA_VISIBLE_DEVICES"] = "0,1"
device = 'cuda:0' if torch.cuda.is_available() else 'cpu'
print('Device:', device)

columns: list
with open("../../src/agent/columns.json", "r", encoding="utf8") as file:
    columns = json.loads(file.read())
print(len(columns))

MAX_LEN = config["agent"]["bert"]["training"]["MAX_LEN"]
LEARNING_RATE = 1e-05
BATCH_SIZE = config["agent"]["bert"]["training"]["TRAIN_BATCH_SIZE"]

tokenizer = PreTrainedTokenizerFast(tokenizer_file="../../src/agent/tokenizer.json")
tokenizer.add_special_tokens({'pad_token': '[PAD]'})
model = BERTClass()
model.to(device)
optimizer = torch.optim.Adam(params=model.parameters(), lr=LEARNING_RATE)
prediction_params = {'batch_size': BATCH_SIZE,
               'shuffle': False,
               'num_workers': 0
               }

load_ckp('../../src/agent/model/checkpoint.pt', model, optimizer)


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


def get_bert_response(requests:list[str]):
    df = pd.DataFrame([{"Message": re.sub("[^A-ZА-ЯЁ ]", "", request.upper())} for request in requests])
    request_set = CustomDataset(df, tokenizer, MAX_LEN)
    request_loader = DataLoader(request_set, **prediction_params)
    prediction = do_prediction(request_loader)
    prediction_df = pd.DataFrame(prediction, columns=columns)
    results = []
    for line in range(len(prediction_df)):
        prediction_line = prediction_df.iloc[line]
        classes_predictions = prediction_line[prediction_line != 0].to_dict()
        sorted_clasees_predictions = sorted(classes_predictions.items(), key=lambda x: x[1], reverse=True)[:1]
        results.append(sorted_clasees_predictions[0][0])
    return results


if __name__ == "__main__":
    # preds = []
    # labels = []
    # df = pd.read_csv("../../src/agent/messages.csv", delimiter="|")
    # for i in range(len(df)):
    #     line = df.iloc[i]
    #     labels.append(line["Label"])
    #     preds.append(get_bert_response([line["Message"]])[0])
    # print(labels)
    # print(preds)
    # cm = confusion_matrix(labels, preds)
    # display = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=columns)
    # display.plot()
    # plt.title("Confusion Matrix")
    # plt.show()

    print(get_bert_response(["Доброе утро"])[0])