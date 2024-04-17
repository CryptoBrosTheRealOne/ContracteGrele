import Web3 from "../node_modules/web3/lib/types/index";

window.addEventListener('load', async () => {
    // Conectarea la Web3 Provider
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        try {
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            console.log('Connected to Web3 Provider');
            
            // Accesarea informațiilor despre cont
            const accounts = await web3.eth.getAccounts();
            const accountAddress = accounts[0];
            console.log('Account address:', accountAddress);
            
            const balance = await web3.eth.getBalance(accountAddress);
            console.log('Account balance:', web3.utils.fromWei(balance, 'ether'), 'ETH');
            
            // Inițierea unei tranzacții de transfer de ETH
            const recipientAddress = '0xRecipientAddress';
            const amountToSend = web3.utils.toWei('0.1', 'ether');
            await web3.eth.sendTransaction({ to: recipientAddress, value: amountToSend });
            console.log('Transaction sent');
            
        } catch (error) {
            console.error('Error connecting to Web3 Provider:', error);
        }
    } else {
        console.error('No Web3 provider detected');
    }
});
