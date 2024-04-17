import React, { useState, useEffect } from 'react';
import Web3 from 'web3';

function App() {
  const [balance, setBalance] = useState(0);

  useEffect(() => {
    if (window.ethereum) {
      // Utilizarea MetaMask ca provider
      const web3 = new Web3(window.ethereum);
      window.ethereum.enable().then((accounts) => {
        // Utilizarea primului cont disponibil
        const address = accounts[0];

        web3.eth.getBalance(address, (err, wei) => {
          setBalance(web3.utils.fromWei(wei, 'ether'));
        });
      });
    } else {
      console.log('MetaMask nu este instalat');
    }
  }, []);

  return (
    <div>
      Balance: {balance} ETH
    </div>
  );
}

export default App;
