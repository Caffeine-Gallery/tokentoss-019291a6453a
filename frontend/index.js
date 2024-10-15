import { backend } from 'declarations/backend';
import { Principal } from '@dfinity/principal';

let userPrincipal;

async function getBalance() {
    try {
        const balance = await backend.icrc1_balance_of(userPrincipal);
        document.getElementById('balanceAmount').textContent = balance.toString();
    } catch (error) {
        console.error('Error fetching balance:', error);
    }
}

async function transfer() {
    const recipientPrincipal = document.getElementById('recipientPrincipal').value;
    const amount = parseInt(document.getElementById('transferAmount').value);

    if (!recipientPrincipal || isNaN(amount)) {
        alert('Please enter valid recipient and amount');
        return;
    }

    try {
        const result = await backend.icrc1_transfer({
            to: Principal.fromText(recipientPrincipal),
            amount: BigInt(amount)
        });

        if ('ok' in result) {
            document.getElementById('result').textContent = `Transfer successful! Index: ${result.ok}`;
            getBalance();
        } else {
            document.getElementById('result').textContent = `Transfer failed: ${result.err}`;
        }
    } catch (error) {
        console.error('Error during transfer:', error);
        document.getElementById('result').textContent = `Transfer failed: ${error.message}`;
    }
}

window.addEventListener('load', async () => {
    // For simplicity, we're using a hardcoded principal here.
    // In a real application, you would use authentication to get the user's principal.
    userPrincipal = Principal.fromText("aaaaa-aa");

    document.getElementById('transferButton').addEventListener('click', transfer);

    await getBalance();
});
