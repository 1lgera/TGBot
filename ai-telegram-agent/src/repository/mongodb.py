from pymongo import MongoClient
from src.config.config import config
import sys
from datetime import datetime
import uuid
from dateutil.parser import isoparse
from datetime import timedelta

sys.path.append("../..")

CONNECTION_URL = config["mongodb"]["url"]
DB_NAME = config["mongodb"]["db_name"]

# Инициализация соединения с MongoDB
client = MongoClient(
    CONNECTION_URL,
    serverSelectionTimeoutMS=config["mongodb"]["serverSelectionTimeoutMS"],
    connectTimeoutMS=config["mongodb"]["connectTimeoutMS"],
    socketTimeoutMS=config["mongodb"]["socketTimeoutMS"],
    maxPoolSize=config["mongodb"]["maxPoolSize"]
)
db = client[DB_NAME]

db.Chats.create_index([("name", 1)], unique=True)

def get_user_by_username(username: str) -> dict:
    try:
        return db.Users.find_one({"username": username})
    except Exception as e:
        print(f"Ошибка при поиске пользователя: {str(e)}")
        return None

def get_user_id_by_username(username: str) -> str:
    if "Users" not in db.list_collection_names():
        return None
    try:
        user = db.Users.find_one({"username": username})
        return user["_id"] if user else None
    except Exception as e:
        print(f"Error retrieving user ID: {str(e)}")
        return None


def get_chat_id_by_name(chat_name: str) -> str:
    if "Chats" not in db.list_collection_names():
        return None
    try:
        chat = db.Chats.find_one({"name": chat_name})
        return chat["_id"] if chat else None
    except Exception as e:
        print(f"Error retrieving chat ID: {str(e)}")
        return None

def get_messages(chat_id: str, user_id: str) -> list:
    messages = []
    if "Messages" not in db.list_collection_names():
        return messages
    try:
        pipeline = [
            {
                "$match": {
                    "chat_id": chat_id,
                    "user_id": user_id
                }
            },
            {
                "$lookup": {
                    "from": "Users",
                    "localField": "user_id",
                    "foreignField": "_id",
                    "as": "user"
                }
            },
            {
                "$lookup": {
                    "from": "Chats",
                    "localField": "chat_id",
                    "foreignField": "_id",
                    "as": "chat"
                }
            },
            {
                "$project": {
                    "content": 1,
                    "send_time": 1,
                    "username": {"$arrayElemAt": ["$user.username", 0]},
                    "chat_name": {"$arrayElemAt": ["$chat.name", 0]}
                }
            }
        ]
        return list(db.Messages.aggregate(pipeline))
    except Exception as e:
        print(f"Error retrieving messages: {str(e)}")
        return []


def get_groups() -> list:
    groups = []
    if "Chats" not in db.list_collection_names():
        return groups
    try:
        pipeline = [
            {
                "$lookup": {
                    "from": "Messages",
                    "let": {"chat_id": "$_id"},
                    "pipeline": [
                        {"$match": {"$expr": {"$eq": ["$chat_id", "$$chat_id"]}}},
                        {"$sort": {"send_time": -1}},
                        {"$limit": 1},
                        {
                            "$lookup": {
                                "from": "Users",
                                "localField": "user_id",
                                "foreignField": "_id",
                                "as": "user"
                            }
                        },
                        {"$unwind": "$user"},
                        {
                            "$project": {
                                "content": 1,
                                "send_time": {"$toString": "$send_time"},  # UTC в строке
                                "username": "$user.username",
                                "_id": 0
                            }
                        }
                    ],
                    "as": "last_message"
                }
            },
            {
                "$lookup": {
                    "from": "Users",
                    "localField": "members",
                    "foreignField": "_id",
                    "as": "users_list"
                }
            },
            {
                "$project": {
                    "_id": 0,
                    "name": 1,
                    "users": {
                        "$map": {
                            "input": "$users_list",
                            "as": "user",
                            "in": "$$user.name"
                        }
                    },
                    "last_message": {
                        "$cond": {
                            "if": {"$gt": [{"$size": "$last_message"}, 0]},
                            "then": {"$arrayElemAt": ["$last_message", 0]},
                            "else": None
                        }
                    }
                }
            }
        ]
        groups = list(db.Chats.aggregate(pipeline))

        # Конвертация времени в GMT+3
        for group in groups:
            if group.get("last_message") and group["last_message"]:
                utc_time = isoparse(group["last_message"]["send_time"])
                gmt3_time = utc_time + timedelta(hours=3)
                group["last_message"]["send_time"] = gmt3_time.strftime("%Y-%m-%d %H:%M:%S")
    except Exception as e:
        print(f"Error retrieving groups: {str(e)}")
    return groups


def save_message(group_name: str, user: str, message: str) -> bool:
    try:
        # Получаем данные пользователя
        user_doc = db.Users.find_one({"username": user})
        if not user_doc:
            return False

        # Ищем чат по названию
        chat = db.Chats.find_one({"name": group_name})

        if not chat:
            # Создаем новый чат с UUID
            chat_id = str(uuid.uuid4())
            chat_doc = {
                "_id": chat_id,
                "name": group_name,
                "members": [user_doc["_id"]],
            }
            db.Chats.insert_one(chat_doc)
        else:
            chat_id = chat["_id"]
            # Добавляем пользователя в участники, если его нет
            db.Chats.update_one(
                {"_id": chat_id},
                {"$addToSet": {"members": user_doc["_id"]}}
            )

        # Сохраняем сообщение
        new_message = {
            "_id": str(uuid.uuid4()),
            "content": message,
            "user_id": user_doc["_id"],
            "chat_id": chat_id,
            "send_time": datetime.utcnow()
        }
        result = db.Messages.insert_one(new_message)
        return result.acknowledged
    except Exception as e:
        print(f"Ошибка сохранения сообщения: {str(e)}")
        return False


def add_user(username: str, name: str) -> bool:
    if "Users" not in db.list_collection_names():
        return False

    try:
        user_id = str(uuid.uuid4())
        user_doc = {
            "_id": user_id,
            "username": username,
            "name": name
        }

        result = db.Users.insert_one(user_doc)
        return result.acknowledged
    except Exception as e:
        print(f"Ошибка добавления пользователя: {str(e)}")
        return False


def get_chat_users(chat_id: str) -> list:
    users = []
    try:
        # Получаем список участников чата
        chat = db.Chats.find_one(
            {"_id": chat_id},
            {"members": 1}
        )
        if not chat or "members" not in chat:
            return []
        member_ids = chat["members"]

        # Поиск пользователей по списку member_ids
        users = list(db.Users.find(
            {"_id": {"$in": member_ids}},
            {"_id": 1, "username": 1, "name": 1}
        ))

    except Exception as e:
        print(f"Ошибка: {str(e)}")

    return users

def get_chat_full_data(chat_name: str) -> dict:
    try:
        # Проверка коллекций
        if "Chats" not in db.list_collection_names() or "Users" not in db.list_collection_names() or "Messages" not in db.list_collection_names():
            return {}

        # Поиск чата по имени
        chat = db.Chats.find_one(
            {"name": chat_name},
            {"_id": 1, "name": 1, "members": 1}
        )
        if not chat:
            return {}

        chat_id = chat["_id"]
        members = chat["members"]

        # Получение участников
        users = list(db.Users.find(
            {"_id": {"$in": members}},
            {"_id": 1, "username": 1, "name": 1}
        ))

        # Получение сообщений
        messages = list(db.Messages.aggregate([
            {"$match": {"chat_id": chat_id}},
            {
                "$lookup": {
                    "from": "Users",
                    "localField": "user_id",
                    "foreignField": "_id",
                    "as": "user"
                }
            },
            {
                "$project": {
                    "content": 1,
                    "send_time": 1,
                    "username": {"$arrayElemAt": ["$user.username", 0]},
                    "user_name": {"$arrayElemAt": ["$user.name", 0]}
                }
            },
            {"$sort": {"send_time": 1}}
        ]))

        return {
            "chat_name": chat["name"],
            "users": [
                {"username": user["username"], "name": user["name"]}
                for user in users
            ],
            "messages": [
            {
                "username": msg["username"],
                "name": msg["user_name"],
                "send_time": msg["send_time"].isoformat(),
                "content": msg["content"]
            } for msg in messages
        ]
        }
    except Exception as e:
        print(f"Ошибка: {str(e)}")
        return {}