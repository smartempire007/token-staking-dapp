import Head from 'next/head';
import { useState, useEffect } from 'react';
import Web3 from 'web3';
import tokenStakeContract from '../staking-contract/stakeToken';
import 'bulma/css/bulma.css';
import styles from '../styles/StakingDapp.module.css';


const StakingDapp = () =>{
    
    const [error, setError] = useState('');
    const [successMsg, setSuccessMsg] = useState('');
    const [myBalanceOf, setMyBalanceOf] = useState('');
    const [myTotalSupply, setMyTotalSupply] = useState('');
    const [buyTokens, setBuyTokens] = useState('');
    const [web3, setWeb3] = useState(null);
    const [address , setAddress] = useState('');
    const [vmContract, setVmContract] = useState(null);
    const [stakeToken, setStakeToken] = useState(null);
    const [claimRewards, setClaimRewards] = useState(null);
    //const [purchases , setPurchases] = useState(0);
    

    useEffect(() => {
        setSuccessMsg('Token purchase successful');
        if (vmContract)getMyTotalSupplyHandler();
        if (vmContract && address)getMyBalanceOfHandler();
    }, [vmContract, address]);

    const getMyBalanceOfHandler = async () => {
        const balance = await vmContract.methods.balanceOf(address).call();
        setMyBalanceOf(balance);
    }

    const getMyTotalSupplyHandler = async () => {
        const myTotalSupply = await vmContract.methods.totalSupply().call();
        setMyTotalSupply(myTotalSupply);
    }

    const updateStakeTokenQty = Event => {
        setStakeToken(Event.target.value);
    }

    const stakeTokenHandler = async () => {
        try {

            await vmContract.methods.stakeToken(stakeToken).send({
                from: address,
                value: web3.utils.toWei('1', 'ether')
            });
            setSuccessMsg(`${stakeToken} stake token successful!`);

        } catch (err) {

            setError(err.message);
        }
        
    }


    const updateTokenQty = Event => {
        setBuyTokens(
            Event.target.value
        );
    }


    const buyTokenHandler = async () => {
        try {

            await vmContract.methods.buyToken(buyTokens).send({
                from: address,
                value: web3.utils.toWei('1', 'ether') * buyTokens
            });
        
            setSuccessMsg(`${buyTokens} Token purchase successful!`);

            if (vmContract)getMyTotalSupplyHandler();
            if (vmContract && address)getMyBalanceOfHandler();

        } catch (err) {

            setError(err.message);
        }
        
    }

    const claimRewardsHandler = async ()  => {
        try {
            
            await vmContract.window.methods.claimReward(claimRewards).send({
                from: address,
            });
            setClaimRewards(claimRewards);
            setSuccessMsg(`${claimRewards} Successfully claimed Rewards`);

        } catch (err) {
    
            setError(err.message);
        }
    }


    // wallet connection using web3
    const connectWalletHandler = async() => {

        // check if metamask is available.
        if (typeof window !== 'undefined' && typeof window.ethereum !== 'undefined') {
            try {

                // Request wallet access if needed
                await window.ethereum.request({ method: 'eth_requestAccounts' })
                
                // set web3 instance
                web3 = new Web3(window.ethereum)
                setWeb3(web3);

                // get the accounts
                const account = await web3.eth.getAccounts();
                setAddress(account[0]);

                // create local contract copy
                const vm = tokenStakeContract(web3);
                setVmContract(vm);

            
            } catch (err) {
                setError(err.message)
            }
        }else {
            //metamask not installed
            console.log('please install metamask');
        }
    }
    return (
        <div className={styles.main}>
            <Head>
                <title>TokenStaking App</title>
                <meta name="description" content="A blockchain token staking app" />
            </Head>
            <nav className='navbar mt-4 mb-4'>
                <div className='container'>
                    <div className='navbar-brand'>
                        <h1>TokenStaking Dapp</h1>
                    </div>
                    <div className='navbar-end'>
                        <button onClick={connectWalletHandler} className='button is-primary'>Connect Wallet</button>
                    </div>
                </div>
            </nav>
            <section>
                <div className='container'>
                    <h2>Token Balance {myBalanceOf}</h2>
                </div>
            </section>

            <section>
                <div className='container'>
                    <h2>My totalSupply: {myTotalSupply}</h2>
                </div>
            </section>

            <section className='mt-5'>
                <div className='container'>
                    <div className='field'>
                        <label className='label'>Stake Token</label>
                        <div className='control'>
                            <input onChange={updateStakeTokenQty} className='input' type='type' placeholder='Stake Tokens...' />
                        </div>
                        <button onClick={stakeTokenHandler} className='button is-primary mt-4'>Stake Tokens</button>
                    </div>
                </div>
            </section>

            <section className='mt-5'>
                <div className='container'>
                    <div className='field'>
                        <label className='label'>Claim Rewards</label>
                        <button onClick={claimRewardsHandler} className='button is-primary mt-4'>Claim Rewards</button>
                    </div>
                </div>
            </section>

            <section className='mt-5'>
                <div className='container'>
                    <div className='field'>
                        <label className='label'>Buy Token</label>
                        <div className='control'>
                            <input onChange={updateTokenQty} className='input' type='type' placeholder='Enter amount...' />
                        </div>
                        <button onClick={buyTokenHandler} className='button is-primary mt-4'>Buy Tokens</button>
                    </div>
                </div>
            </section>

            <section>
                <div className='container has-text-danger'>
                    <p>{error}</p>
                </div>
            </section>

            <section>
                <div className='container has-text-success'>
                    <p>{successMsg}</p>
                </div>
            </section>
        </div>
    )
}

export default StakingDapp;