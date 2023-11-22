<script lang="ts">
	import { stringify } from "postcss";
  import { onMount } from 'svelte';
  import { chart } from "svelte-apexcharts?client";
  import {ethers} from "ethers";
  
  export let series: number[];
  const tokenomicNames = ["team", "liquidity", "marketing", "investors", "crowdfund"]
  let options = {
    series: series,
    labels: tokenomicNames,
    chart: {
      height: screen.height/4,
      type: 'donut',
      foreColor: '#e5e7eb'
    },
    legend: {
      fontSize: "32px",
      color: "white"
      },
  responsive: [{
    breakpoint: 480,
    options: {
      chart: {
        width: 10
      },

    }
  }]
};

</script>

<div class="object-contain">
  <h1 class="text-4xl">Tokenomics</h1>
  <div use:chart={options} />
</div>
