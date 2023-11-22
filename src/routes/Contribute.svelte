<script lang="ts">
	import { ethers } from "ethers";

    export let contract: ethers.Contract;
    export let provider: ethers.BrowserProvider;

    let amount: number;

    const contribute = async function(){
        const accounts = await provider.listAccounts();
        const signer = await provider.getSigner(accounts[0].address);
        let tx: ethers.TransactionRequest = {
            to: contract.getAddress(),
            value: ethers.parseEther(amount.toString())
        };
        const transaction = await signer.sendTransaction(tx);
    }

</script>
<input type="number" placeholder="Amount" bind:value={amount}>
<button class="btn btn-outline w-1/2 btn-accent" on:click={contribute}>Contribute</button>