from flask import Flask, render_template, jsonify, request, session
import json
import time
import datetime

app = Flask(__name__)
app.secret_key = b'aszg19kl@'
coffees = dict()
orders = dict()
order_id = 1


@app.route('/')
def root():
    return render_template('index.html')


def get_fail_json(msg):
    return json.dumps({'result': 'fail', 'data': msg})


def get_success_json(data):
    return json.dumps({'result': 'success', 'data': data})


@app.route('/ajax/get_data', methods=['POST'])
def get_data():
    req = request.get_json()
    print(req)

    if req['cmd'] == 'get_coffees':
        return get_success_json(coffees)
    elif req['cmd'] == 'get_orders':
        return get_success_json(orders)
    elif req['cmd'] == 'get_name':
        if 'name' in session:
            return get_success_json(session['name'])
        return get_success_json('')
    else:
        return get_fail_json('unknown cmd')


@app.route('/ajax/set_data', methods=['POST'])
def set_data():
    global order_id
    req = request.get_json()
    print(req)

    if req['cmd'] == 'add_order':
        if 'name' in session:
            order = req['data']
            order['id'] = str(order_id)
            order_id += 1
            order['주문자'] = session['name']
            orders[order['id']] = order
            return get_success_json('add order success')
        return get_fail_json('unknown user')
    elif req['cmd'] == 'remove_order':
        if req['data'] in orders:
            del orders[req['data']]
            return get_success_json('remove order success')
        return get_fail_json('unknown order id')
    elif req['cmd'] == 'set_name':
        session['name'] = req['data']
        return get_success_json('set name success')
    else:
        return get_fail_json('unknown cmd')


if __name__ == '__main__':
    with open('coffee.json', encoding='utf-8') as json_file:
        coffees = json.load(json_file)
    order_id = 1
    app.run(host='0.0.0.0', port='80')

