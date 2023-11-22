<script lang="ts">
    export let raisedFunds: number;
    export let goal: number;
  </script>
  
  <div class="thermometer-container my-auto">
    <p class="text-xl">Progress</p>
    <progress class="progress progress-success w-11/12 h-10" value="{raisedFunds}" max="{goal}"></progress>
  </div>
  