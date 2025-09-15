import sys
sys.path.append("../..")
import src.agent.agent as agent
import src.repository.mongodb as mongodb
import src.agent.custom_bert_usage as bert

def get_user_by_username(username: str) -> dict:
    return mongodb.get_user_by_username(username)

def add_user(username: str, name: str) -> bool:
    return mongodb.add_user(username, name)

def save_message(group_name: str, user: str, message: str) -> bool:
    return mongodb.save_message(group_name, user, message)

def get_messages(chat_id: str, user_id: str) -> list:
    return mongodb.get_messages(chat_id, user_id)

def get_chat_id_by_name(chat_name: str) -> str:
    return mongodb.get_chat_id_by_name(chat_name)

def get_user_id_by_username(username: str) -> str:
    return mongodb.get_user_id_by_username(username)

def get_groups() -> []:
    return mongodb.get_groups()

def get_chat_full_data(chat_name: str) -> dict:
    return mongodb.get_chat_full_data(chat_name)

def get_system_prompt() -> str:
    return agent.get_system_prompt()

def update_system_prompt(new_prompt: str):
    return agent.update_system_prompt(new_prompt)

def get_llm_reponse(message:str, model:str):
    return agent.get_llm_response(message, model)

def get_llm_reponse_list(message:list[str], model:str):
    return agent.get_llm_response_list(message, model)

def get_bert_response(requests:list[str]) -> list[str]:
    return bert.get_bert_response(requests)

def get_chat_users(chat_id: str) -> list:
    return mongodb.get_chat_users(chat_id)