<script lang="ts">
	import type { ethers } from "ethers";

    export let contract: ethers.Contract;

    const claim = async function(){
        console.log(contract)
        await contract.claim();
    }

</script>

<button class="btn btn-outline w-1/2 btn-accent" on:click={claim}>Claim</button>