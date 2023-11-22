<script lang="ts">
    import Header from './Header.svelte';
    import Thermometer from './Thermometer.svelte';
    import ProjectExplanation from './ProjectExplanation.svelte';
    import PieChart from './PieChart.svelte';
    import Footer from './Footer.svelte';
    import Contribute from './Contribute.svelte';
    import Claim from './Claim.svelte';
    import { onMount } from 'svelte';
    import {ethers, Contract} from "ethers";
    import {address, abi} from '../../deployments/localhost/CrowdFund.json'; // Replace with your contract

    let raisedFunds: number = 0;
    let goal: number = 0;
    let endTime: number = 0;
    let provider: ethers.BrowserProvider;
    let contract: ethers.Contract;
    let isWalletConnected: boolean = false;
    let signer: ethers.Signer;
    let tokenomics: Tokenomics;
    let tokenomicsLoaded: boolean;

    type Tokenomics = {
      team: string,
      liquidity: string,
      marketing: string,
      investors: string,
      crowdFund: string
    }

    const connect = async function(){
      if (window.ethereum == null) {
        console.log("Metamask not installed... Use will be limited")
      }else{
        if(!isWalletConnected){
            provider = new ethers.BrowserProvider(window.ethereum);
            signer = await provider.getSigner();
            contract = new Contract(address, abi, signer);
        }
        isWalletConnected = true;
      }
    }

    onMount(async () => {
      const jsonrpcProvider = new ethers.JsonRpcProvider();
      console.log("Using address: " + address)

      if (jsonrpcProvider) {

        const readOnlyContract = new Contract(address, abi, jsonrpcProvider);
        goal = Number(ethers.formatEther(await readOnlyContract.fundingGoal()));
        endTime = Number(await readOnlyContract.endTime());

        await loadData(readOnlyContract, jsonrpcProvider);
        readOnlyContract.on("NewContribution", async (event: Event) => {
              console.log("Event emitted:", event);
              await loadData(readOnlyContract, jsonrpcProvider);
          });

      }else{
          console.log("no provider")
      }
    });

    async function loadData(contract:ethers.Contract, provider:ethers.JsonRpcProvider |ethers.BrowserProvider){
        raisedFunds = Number(ethers.formatEther(await provider.getBalance(address)));
        tokenomics = await contract.tokenomics() as Tokenomics;
        tokenomicsLoaded = true;
    }

    function getTokenomicsAsNumbers(){
      let list = Object.values(tokenomics)
      let newList = list.map((e)=>{
          return Number(ethers.formatEther(e))
        });
      return newList;
    }
  </script>
  
  
  <main>
    <div class="container mx-auto">
      <div class="my-8">
        <Header {raisedFunds} {goal} />
      </div>
      <div class="grid grid-cols-2 gap-4">
        <Thermometer {raisedFunds} {goal} />
        <ProjectExplanation />
        {#if tokenomicsLoaded}
        <PieChart series={getTokenomicsAsNumbers()} />
        {/if}

        <div class="text-center my-32">
          {#if raisedFunds >= goal}
            <h1 class="text-4xl my-6">Funding Complete!</h1>
          {:else}
            {#if isWalletConnected}
              {#if Date.now() / 1000 >= endTime}
                <Claim contract={contract}/>
                {:else}
                <Contribute contract={contract} provider={provider} />
              {/if}
            {:else}
              <button class="btn btn-outline w-1/2 btn-accent" on:click={connect}>Connect Wallet</button>            
            {/if}
          {/if}
        </div>

      </div>
    </div>
  </main>
  
  <Footer />
  