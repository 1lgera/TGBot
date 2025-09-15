from collections import Counter
from datetime import timedelta

from dateutil.parser import isoparse
from flask import Flask, request, jsonify, make_response
from flask_cors import CORS, cross_origin
import flask.wrappers
import sys
sys.path.append("../..")
import src.service.service as service

# Создание Flask приложения и его конфигурация
app = Flask(__name__)
cors = CORS(app, methods=["GET", "POST", "DELETE", "OPTIONS"], origins=["http://localhost:8080", "http://flutter_web:8080"], supports_credentials=True)
app.config["JSON_AS_ASCII"] = False
app.config["JSONIFY_MIMETYPE"] = "application/json; charset=utf-8"
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
app.config['CORS_HEADERS'] = 'Content-Type'


# Метод, который срабатывает до выполнения любого запроса
@cross_origin()
@app.before_request
def filter_jwt():
    request_cookies = request.cookies
    request_args = request.args
    request_path = request.path
    request_method = request.method
    print(request_path)
    print(request_method)


# Аннотация after_request выполняется после любого запроса Flask.
@cross_origin()
@app.after_request
def after_response(response: flask.wrappers.Response):
    # Дополняю все запросы CORS для фронта
    if "Access-Control-Allow-Credentials" not in response.headers:
        response.headers.add("Access-Control-Allow-Credentials", "true")
    if "Access-Control-Allow-Origin" not in response.headers:
        response.headers.add("Access-Control-Allow-Origin", "*")
    if "Access-Control-Allow-Headers" not in response.headers:
        response.headers.add("Access-Control-Allow-Headers", "*")
    if "Access-Control-Allow-Methods" not in response.headers:
        response.headers.add("Access-Control-Allow-Methods", "*")
    # Вывод ошибки при запросе
    if response.status_code != 200 and response.status_code != 304:
        print(response.data)
    return response

@cross_origin()
@app.route('/healthcheck')
def healthcheck():
    return jsonify(status="OK"), 200

@cross_origin()
@app.route("/api/message", methods=["POST"])
def send_message_api():
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "No message provided"}), 400

    user_message = data['message']
    model = "DEEPSEEK"

    try:
        bert_response = service.get_bert_response([user_message])[0]  # ← Сразу берем строку

        llm_response = service.get_llm_reponse(user_message, model)

        # Формируем ответ
        return jsonify({
            "message": user_message,
            "bert_response": bert_response,
            "llm_response": llm_response
        })

    except IndexError:
        return jsonify({
            "error": "BERT не вернул результат для сообщения"
        }), 500
    except Exception as e:
        return jsonify({"error": f"Ошибка: {str(e)}"}), 500


@app.route("/api/messages", methods=["GET"])
def get_messages_api():
    username = request.args.get("username")
    chat_name = request.args.get("chat_name")

    if not all([username, chat_name]):
        return jsonify({"error": "username and chat_name required"}), 400

    try:
        user_id = service.get_user_id_by_username(username)
        chat_id = service.get_chat_id_by_name(chat_name)

        if not user_id:
            return jsonify({"error": f"User '{username}' not found"}), 404
        if not chat_id:
            return jsonify({"error": f"Chat '{chat_name}' not found"}), 404

        messages = service.get_messages(chat_id, user_id) or []

        processed_messages = [
            {"content": msg["content"]} for msg in messages
        ] if messages else []

        bert_labels = service.get_bert_response([msg["content"] for msg in messages]) if messages else []

        label_counts = Counter(bert_labels)
        formatted_bert = [
            f"{label} ({count} message{'s' if count != 1 else ''})"
            for label, count in label_counts.items()
        ] if bert_labels else []

        llm_response = service.get_llm_reponse_list(
            [msg["content"] for msg in messages], model="DEEPSEEK"
        ) if messages else []

        return jsonify({
            "messages": processed_messages,
            "bert_classification": formatted_bert,
            "llm_response": llm_response
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Запрос на все чаты
@cross_origin()
@app.route("/api/chats", methods=["GET"])
def get_all_chats_api():
    try:
        chats = service.get_groups()
        return jsonify(chats)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Запрос на всех юзеров чата
@cross_origin()
@app.route("/api/chat/users", methods=["GET"])
def get_chat_users_api():
    chat_name = request.args.get("chat_name")
    if not chat_name:
        return jsonify({"error": "chat_name required"}), 400

    try:
        chat_id = service.get_chat_id_by_name(chat_name)
        if not chat_id:
            return jsonify({"error": f"Chat '{chat_name}' not found"}), 404

        users = service.get_chat_users(chat_id)
        return jsonify(users)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Получение System-prompt
@cross_origin()
@app.route("/api/system-prompt", methods=["GET"])
def get_system_prompt_api():
    try:
        system_prompt = service.get_system_prompt()
        return jsonify({"system_prompt": system_prompt})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Изменение System-prompt
@cross_origin()
@app.route("/api/system-prompt", methods=["POST"])
def update_system_prompt_api():
    data = request.get_json()
    if not data or 'system_prompt' not in data:
        return make_response(jsonify({"error": "No system_prompt provided"}), 400)

    new_prompt = data['system_prompt']
    try:
        service.update_system_prompt(new_prompt)
        system_prompt = service.get_system_prompt()
        return jsonify({"success": True, "new prompt": system_prompt})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/chat/data", methods=["GET"])
@cross_origin()
def get_chat_full_data_api():
    chat_name = request.args.get("chat_name")
    if not chat_name:
        return jsonify({"error": "chat_name required"}), 400

    try:
        chat_data = service.get_chat_full_data(chat_name)
        if not chat_data:
            return jsonify({"error": f"Chat '{chat_name}' not found"}), 404

        for msg in chat_data["messages"]:
            utc_time = isoparse(msg["send_time"])
            gmt3_time = utc_time + timedelta(hours=3)
            msg["send_time"] = gmt3_time.strftime("%Y-%m-%d %H:%M:%S")

        return jsonify(chat_data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Запуск Flask приложения. Если нужен https, добавьте ..., port=5001, ssl_context=ssl_context) Либо ..., port=5001, dummy_context=dummy_context) Для ssl_context сгенерируйте свой ssl сертификат.
if __name__ == '__main__':
    ssl_context = ("cert.pem", "key.pem")
    dummy_context = "adhoc"
    app.run(host='0.0.0.0', port=5001)