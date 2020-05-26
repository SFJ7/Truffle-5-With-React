import React, { Component } from "react";
import RockPaperScissorsContract from "./contracts/RockPaperScissors.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  state = { storageValue: 0, challenges: [], web3: null, accounts: null, contract: null, challengeCreatorPrice: 0, challengeCreatorChoice: '' };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = RockPaperScissorsContract.networks[networkId];
      const instance = new web3.eth.Contract(
          RockPaperScissorsContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.initContract);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }

  };



  initContract = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    // await contract.methods.set(5).send({ from: accounts[0] });
    contract.options.address = accounts[0];
    let challenges = [];
    try {
      challenges = await contract.methods.getChallengesStillAvailable().call();
    } catch(error) {
      console.error(error);
    }

    // Get the value from the contract to prove it worked.
    // const response = await contract.methods.get().call();

    // Update state with the result.
    this.setState({ challenges });
  };

  // handleChange(event) {
  //   this.setState({challengeValue: [...challengeValues, {id: event.target.name, value: event.target.value}]})
  // }

  renderChallenges = () => {
    return this.state.challenges.map(challenge => {
      return (
          <div className="col-lg-4 col-md-4 col-sm-4 col-xs-12">

            <div className="box-part text-center">

              <div className="title">
                <h4>Account Name</h4>
              </div>

              <div className="text">
                <span>Wants to play for {this.state.web3.utils.fromWei(challenge.price, "ether")} Ethereum</span>
              </div>
              {/*<form onSubmit={this.handleSubmit}>*/}
              {/*  <input type='text' value={this.state.choice} name={challenge.id} onChange={this.handleChange.bind(this)}/>*/}
              {/*  <button type='submit' value='Submit rock, paper or scissors' />*/}
              {/*</form>*/}

            </div>
          </div>
      )
    })

  }

  handleChallengeChange(event) {
    this.setState({challengeCreatorChoice: event.target.value})
  }

  async createChallengeSubmit(event) {
    event.preventDefault();
    const {accounts, contract, challengeCreatorChoice, challengeCreatorPrice} = this.state;
    await contract.methods.createChallenge(challengeCreatorChoice, challengeCreatorPrice).send({from: accounts[0], gas: 5000000});
    const challenges = await contract.methods.getChallengesStillAvailable()
                                   .call();
    this.setState({challenges})

  }

  handleChallengePriceChange(event) {
    this.setState({challengeCreatorPrice: event.target.value})
  }

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <header>
          <div className='navbar navbar-dark bg-dark shadow-sm'>
            <div className='container d-flex justify-content-between'>
              <div className='navbar-brand d-flex align-items-center'>
                <strong>Rock Paper Scissors for Ethereum!</strong>
              </div>
            </div>
          </div>
        </header>
        <h1>Create a rock paper scissors challenge!</h1>
        <p>Enter your challenge info</p>
        <form onSubmit={this.createChallengeSubmit.bind(this)}>
          <label htmlFor='choice'>Please enter ONLY rock, paper or scissors</label>
          <input type='text' id='choice' value={this.state.challengeCreatorChoice} onChange={this.handleChallengeChange.bind(this)} />
          <label htmlFor='price'>Please enter the amount of Ethereum to play for</label>
          <input type='number' id='price' value={this.state.challengeCreatorPrice} onChange={this.handleChallengePriceChange.bind(this)} />
          <button type='submit'>Submit Challenge</button>
        </form>

        {/*<p>*/}
        {/*  If your contracts compiled and migrated successfully, below will show*/}
        {/*  a stored value of 5 (by default).*/}
        {/*</p>*/}
        {/*<p>*/}
        {/*  Try changing the value stored on <strong>line 40</strong> of App.js.*/}
        {/*</p>*/}
        {/*<div>The stored value is: {this.state.storageValue}</div>*/}
        <div className='box'>
          <div className='container'>
            <div className='row'>
              {this.renderChallenges()}
            </div>
          </div>
        </div>

      </div>
    );
  }
}

export default App;
