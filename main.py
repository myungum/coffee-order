from flask import Flask, render_template, jsonify, request, session
import json
import threading
import clipboard
import ctypes

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


def get_orders_str():
    result = ''
    orders_by_coffee_name = dict()
    for order in orders.values():
        options = ''
        for option in order['옵션'].values():
            options += ('/' if len(options) > 0 else '') + option
        if order['이름'] not in orders_by_coffee_name:
            orders_by_coffee_name[order['이름']] = dict()

        if options not in orders_by_coffee_name[order['이름']]:
            orders_by_coffee_name[order['이름']][options] = 0
        orders_by_coffee_name[order['이름']][options] += 1

    for coffee_name, orders_by_options in orders_by_coffee_name.items():
        for options, count in orders_by_options.items():
            result += coffee_name + ' ' + str(count) + '개 ' + options + '\n'

    return result


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
    elif req['cmd'] == 'get_orders_str':
        return get_success_json(get_orders_str())
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
    elif req['cmd'] == 'clear_order':
        orders.clear()
        return get_success_json('clear order success')
    else:
        return get_fail_json('unknown cmd')


class Worker(threading.Thread):
    def __init__(self, _app, _ip, _port):
        super().__init__()
        self.app = _app
        self.ip = _ip
        self.port = _port

    def run(self):
        app.run(host=self.ip, port=self.port)

    def get_id(self):
        # returns id of the respective thread
        if hasattr(self, '_thread_id'):
            return self._thread_id
        for id, thread in threading._active.items():
            if thread is self:
                return id

    def raise_exception(self):
        thread_id = self.get_id()
        res = ctypes.pythonapi.PyThreadState_SetAsyncExc(thread_id,
              ctypes.py_object(SystemExit))
        if res > 1:
            ctypes.pythonapi.PyThreadState_SetAsyncExc(thread_id, 0)
            print('Exception raise failure')


if __name__ == '__main__':
    abort = False
    while not abort:
        with open('coffee.json', encoding='utf-8') as json_file:
            coffees = json.load(json_file)
        order_id = 1
        worker = Worker(app, '0.0.0.0', '80')
        worker.start()

        while True:
            cmd = input().split()
            if cmd[0] == 'print':
                print(get_orders_str())
            elif cmd[0] == 'copy':
                clipboard.copy(get_orders_str())
            elif cmd[0] == 'export':
                with open(cmd[1] if len(cmd) > 1 else 'output.txt', 'w', encoding='utf-8') as file:
                    file.write(get_orders_str())
            # thread abort : https://pythondocs.net/%ED%8C%8C%EC%9D%B4%EC%8D%AC%EA%B8%B0%EC%B4%88/%ED%8C%8C%EC%9D%B4%EC%8D%AC-%EC%93%B0%EB%A0%88%EB%93%9Cthread%EB%A5%BC-%EC%A4%91%EA%B0%84%EC%97%90-%EC%A4%91%EB%8B%A8kill-terminate%EC%8B%9C%ED%82%A4%EB%8A%94%EB%B2%95/
            elif cmd[0] == 'exit' or cmd[0] == 'stop':
                worker.raise_exception()
                worker.join()
                abort = True
                break
            elif cmd[0] == 'reboot' or cmd[0] == 'restart':
                worker.raise_exception()
                worker.join()
                break
            elif cmd[0] == 'clear':
                orders.clear()
                break
            else:
                print('unknown command')

