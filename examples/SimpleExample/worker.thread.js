import { self } from 'react-native-threads';
import './config';

let count = 0;

self.onmessage = message => {
  console.tron.log(`THREAD: got message ${message}`);

  count++;

  self.postMessage(`Message #${count} from worker thread!`);
}

for(var i = 0; i<10; i++) { console.log('Custom thread is running at: ' + Date.now()); }

