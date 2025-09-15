import ollama
import json
import requests
import sys
from openai import OpenAI
sys.path.append("../..")
from src.config.config import config

# Получение конфигураций из файла config.yml
OLLAMA_URL = config["agent"]["ollama"]["url"]
OLLAMA_MODEL = config["agent"]["ollama"]["model"]
SYSTEM_PROMPT = config["agent"]["ollama"]["system-prompt"]

HUGGINGFACE_API_TOKEN = config["agent"]["qwen"]["api_token"]
HUGGINGFACE_MODEL_NAME = config["agent"]["qwen"]["model_name"]

DEEPSEEK_API_TOKEN = config["agent"]["deepseek"]["api_token"]
DEEPSEEK_MODEL = config["agent"]["deepseek"]["model"]
DEEPSEEK_CLIENT = OpenAI(api_key=DEEPSEEK_API_TOKEN, base_url="https://api.deepseek.com")

PARAMETERS_TEMPERATURE = config["agent"]["parameters"]["temperature"]
PARAMETERS_TOP_P = config["agent"]["parameters"]["top_p"]
PARAMETERS_MAX_TOKENS = config["agent"]["parameters"]["max_tokens"]

# Функция возвращающая SYSTEM_PROMPT 0_0
def get_system_prompt() -> str:
    return SYSTEM_PROMPT

# Функция изменения SYSTEM_PROMPT (Только в текущей сессии)
def update_system_prompt(new_prompt: str) -> None:
    global SYSTEM_PROMPT
    SYSTEM_PROMPT = new_prompt
    print("Системный промпт успешно обновлён.")

# Функция для сообщения через OLLAMA
def get_ollama_response(messages: list) -> str:
    response = ollama.chat(
        model = OLLAMA_MODEL,
        messages = messages,
        stream = False,
        options={
            'temperature' : PARAMETERS_TEMPERATURE,
            'top_p' : PARAMETERS_TOP_P,
            'max_tokens' : PARAMETERS_MAX_TOKENS
        }
    )

    return response.json()["message"]["content"]

#Функция для сообщения через API ключ
def get_huggingface_response(messages: list) -> str:
    headers = {
        "Authorization": f"Bearer {HUGGINGFACE_API_TOKEN}",
        "Content-Type": "application/json"
    }

    combined_messages = "\n".join([f"{msg['role']}: {msg['content']}" for msg in messages])

    data = {
        "inputs": combined_messages,
        "parameters": {
            "temperature": PARAMETERS_TEMPERATURE,
            "top_p": PARAMETERS_TOP_P,
            "max_new_tokens": PARAMETERS_MAX_TOKENS
        }
    }

    response = requests.post(
        f"https://api-inference.huggingface.co/models/{HUGGINGFACE_MODEL_NAME}",
        headers=headers,
        json=data
    )
    
    if response.status_code == 200:
        full_text = response.json()[0]['generated_text']
        assistant_start = full_text.find("assistant:") + len("assistant:")
        return full_text[assistant_start:].strip()
        #return f"\n{response.json()[0]['generated_text']}"
    else:
        raise Exception(f"Ошибка при запросе к Hugging Face API: {response.status_code} {response.text}")

def get_deepseek_response(messages: list) -> str:
    response = DEEPSEEK_CLIENT.chat.completions.create(
        model=DEEPSEEK_MODEL,
        messages=messages,
        stream=False
    )
    return response.choices[0].message.content

# Это адаптер для работы с функциями выше
llm_func_map = {
    "OLLAMA": get_ollama_response,
    "HUGGINGFACE": get_huggingface_response,
    "DEEPSEEK": get_deepseek_response
}

# Общий метод получения ответа от LLM на одно сообщение
def get_llm_response(message:str, model:str) -> str:
    if model not in llm_func_map:
        raise Exception("Model is not supported")
    llm_func = llm_func_map[model]
    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT
        },
        {
            "role": "user",
            "content": message
        }
    ]
    response = llm_func(messages)
    return response

# Общий метод получения ответа от LLM на список сообщений
def get_llm_response_list(messages: list, model: str) -> str:
    if model not in llm_func_map:
        raise Exception("Model is not supported")
    llm_func = llm_func_map[model]

    formatted_messages = []
    for msg in messages:
        formatted_messages.append(f"\t- {msg}\n")
    messages_str = "".join(formatted_messages).rstrip()

    user_prompt = f"""
    Ниже приведён контекст сообщений пользователя:
    ---
    {messages_str}
    ---
    """

    messages_full = [
        {
            "role" : "system",
            "content" :f"\n{SYSTEM_PROMPT}"
        },
        {
            "role": "user",
            "content": user_prompt
        }
    ]
    response = llm_func(messages_full)
    return response

if __name__ == "__main__":
    # message1 = "Привет всем"
    # message2 = "Сорри, сегодня голова не варит. Попробую завтра утром доделать"
    # message3 = "Всё нормально, просто напился вчера и до сих пор не отошёл"

    # messages = [message1, message2, message3]

    # try:
    #     response = get_llm_response_list(message2, "OLLAMA")
    #     print("LLM response: ")
    #     print(response)
    # except Exception as e:
    #     print(f"Exception: {e}")

    # try:
    #     response = get_llm_response_list(messages, "HUGGINGFACE")
    #     print("LLM response: ")
    #     print(response)
    # except Exception as e:
    #     print(f"Exception: {e}")


    current_system_prompt = get_system_prompt()
    print("Текущий системный промпт:")
    print(current_system_prompt)

    new_prompt = """
    Ты - новый агент в чате, твоя задача - анализировать сообщения и давать рекомендации.
    1) Определить эмоциональный тон.
    2) Дать рекомендации по улучшению настроения.
    """
    update_system_prompt(new_prompt)

    updated_system_prompt = get_system_prompt()
    print("Обновлённый системный промпт:")
    print(updated_system_prompt)