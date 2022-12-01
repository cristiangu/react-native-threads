import { self } from 'react-native-threads';
import './config';


for(var i = 0; i<10; i++) { console.log('New thread started to run ' + Date.now()); }

let count = 0;

self.onmessage = message => {
  console.tron.log(`THREAD: got message ${message}`);

  count++;

  self.postMessage(`Message #${count} from worker thread!`);
}

setInterval(() => {
  self.postMessage(Date().toString());
}, 1000)



