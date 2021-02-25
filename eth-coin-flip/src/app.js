App = {
  
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
    
  },

  // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      window.alert("Please connect to Metamask.")
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  },

  loadAccount: async () => {
    // Set the current blockchain account
    App.account = web3.eth.accounts[0]
  },

  loadContract: async () => {
    // Create a JavaScript version of the smart contract
    const CoinFlip = await $.getJSON('CoinFlip.json')
    App.contracts.CoinFlip = TruffleContract(CoinFlip)
    App.contracts.CoinFlip.setProvider(App.web3Provider)

    // Hydrate the smart contract with values from the blockchain
    App.CoinFlip = await App.contracts.CoinFlip.deployed()
  },

  // UPDATE ----------------------------------------
  render: async () => {
    // Prevent double render
    if (App.loading) {
      return
    }

    // Render Account
    $('#account').html(App.account)

    // Render Tasks
    await App.renderTasks()

    // Update loading state
    // App.setLoading(false)
  },

  // renderTasks: async () => {
  //   // Load the total task count from the blockchain
  //   const taskCount = await App.CoinFlip.taskCount()
  //   const $taskTemplate = $('.taskTemplate')

  //   // Render out each task with a new task template
  //   for (var i = 1; i <= taskCount; i++) {
  //     // Fetch the task data from the blockchain
  //     const task = await App.CoinFlip.tasks(i)
  //     const taskId = task[0].toNumber()
  //     const taskContent = task[1]
  //     const taskCompleted = task[2]

  //     // Create the html for the task
  //     const $newTaskTemplate = $taskTemplate.clone()
  //     $newTaskTemplate.find('.content').html(taskContent)
  //     $newTaskTemplate.find('input')
  //                     .prop('name', taskId)
  //                     .prop('checked', taskCompleted)
  //                     // .on('click', App.toggleCompleted)

  //     // Put the task in the correct list
  //     if (taskCompleted) {
  //       $('#completedTaskList').append($newTaskTemplate)
  //     } else {
  //       $('#taskList').append($newTaskTemplate)
  //     }

  //     // Show the task
  //     $newTaskTemplate.show()
  //   }
  // },

}

$(() => {

  $(window).load(() => {
    // executes when complete page is fully loaded, including all frames, objects and images
    // alert("window is loaded");
    // App.load()
    // let secretChoice = ""
  })


  $(function() {
    // executes when HTML-Document is loaded and DOM is ready
    // alert("document is ready");
     
    $('#coin').on('click', function(){
    var flipResult = Math.random();
    $('#coin').removeClass();
    setTimeout(function(){
      if(flipResult <= 0.5){
        $('#coin').addClass('heads');
        console.log('it is head');
        // alert('it is head');

      }
      else{
        $('#coin').addClass('tails');
        console.log('it is tails');
        // alert('it is tails');
        }
      }, 100);
    });
 
  });

})

App = {
  
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
    
  },

  // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      window.alert("Please connect to Metamask.")
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  },

  loadAccount: async () => {
    // Set the current blockchain account
    App.account = web3.eth.accounts[0]
  },

  loadContract: async () => {
    // Create a JavaScript version of the smart contract
    const CoinFlip = await $.getJSON('CoinFlip.json')
    App.contracts.CoinFlip = TruffleContract(CoinFlip)
    App.contracts.CoinFlip.setProvider(App.web3Provider)

    // Hydrate the smart contract with values from the blockchain
    App.CoinFlip = await App.contracts.CoinFlip.deployed()
  },

  // UPDATE ----------------------------------------
  render: async () => {
    // Prevent double render
    if (App.loading) {
      return
    }

    // Render Account
    $('#account').html(App.account)

    // Render Tasks
    await App.renderTasks()

    // Update loading state
    // App.setLoading(false)
  },

  // renderTasks: async () => {
  //   // Load the total task count from the blockchain
  //   const taskCount = await App.CoinFlip.taskCount()
  //   const $taskTemplate = $('.taskTemplate')

  //   // Render out each task with a new task template
  //   for (var i = 1; i <= taskCount; i++) {
  //     // Fetch the task data from the blockchain
  //     const task = await App.CoinFlip.tasks(i)
  //     const taskId = task[0].toNumber()
  //     const taskContent = task[1]
  //     const taskCompleted = task[2]

  //     // Create the html for the task
  //     const $newTaskTemplate = $taskTemplate.clone()
  //     $newTaskTemplate.find('.content').html(taskContent)
  //     $newTaskTemplate.find('input')
  //                     .prop('name', taskId)
  //                     .prop('checked', taskCompleted)
  //                     // .on('click', App.toggleCompleted)

  //     // Put the task in the correct list
  //     if (taskCompleted) {
  //       $('#completedTaskList').append($newTaskTemplate)
  //     } else {
  //       $('#taskList').append($newTaskTemplate)
  //     }

  //     // Show the task
  //     $newTaskTemplate.show()
  //   }
  // },

}

$(() => {

  $(window).load(() => {
    // executes when complete page is fully loaded, including all frames, objects and images
    // alert("window is loaded");
    // App.load()
    var secretChoice = document.getElementById("tails").value;
    console.log(secretChoice)

    // function storeVar(el) {
    //   var amount = el.getAttribute('value'); 
    //   // OR: simply 
    //   // var amount = el.value;
    //   console.log(amount);
    // } 
  })


  $(function() {
    // executes when HTML-Document is loaded and DOM is ready
    // alert("document is ready");
     
    $('#coin').on('click', function(){
    var flipResult = Math.random();
    $('#coin').removeClass();
    setTimeout(function(){
      if(flipResult <= 0.5){
        $('#coin').addClass('heads');
        console.log('it is head');
        // alert('it is head');

      }
      else{
        $('#coin').addClass('tails');
        console.log('it is tails');
        // alert('it is tails');
        }
      }, 100);
    });
 
  });

})

