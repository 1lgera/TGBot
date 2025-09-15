import telebot
from telebot.types import Message
import sys
import uuid

sys.path.append("../..")
from src.service.service import get_user_by_username, add_user, save_message, get_bert_response, get_llm_reponse_list
from src.config.config import config

BOT_TOKEN = config["telegram"]["bot"]["token"]
bot = telebot.TeleBot(BOT_TOKEN)

@bot.message_handler(content_types=['text'])
def on_message(message: Message):
    chat_id = message.chat.id
    username = message.from_user.username or "no_username"
    user_full_name = message.from_user.full_name
    message_text = message.text

    if message.chat.type in ['group', 'supergroup']:
        group_name = message.chat.title  # Используем название группы

        # Проверяем и добавляем пользователя
        existing_user = get_user_by_username(username)
        if not existing_user:
            add_user_result = add_user(username, user_full_name)
            if not add_user_result:
                bot.send_message(chat_id, f"Не удалось добавить пользователя {username}.")
                return

        # Сохраняем сообщение с передачей названия группы
        success = save_message(
            group_name=group_name,
            user=username,
            message=message_text
        )
        if success:
            print(f"Сообщение от {user_full_name} сохранено в группе: {group_name}")
        else:
            print(f"Error")
    else:
        # Для личных сообщений
        bert_response = get_bert_response([message_text])[0]
        bot.send_message(
            chat_id,
            f"Bert response: {bert_response}"
        )
        # Test
        model = "DEEPSEEK"
        agent_response = get_llm_reponse_list([message_text], model)
        bot.send_message(
            chat_id,
            f"Agent response: {agent_response}"
        )

if __name__ == "__main__":
    print("Бот запущен...")
    bot.infinity_polling()