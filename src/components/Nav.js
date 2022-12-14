import '../App.css';
import { HashLink as Link } from 'react-router-hash-link';
import * as FaIcons from 'react-icons/fa';

function Nav(props) {

  const isConnected = Boolean(props.accounts[0]);

  async function connectAccount() {
    
    if (window.ethereum) {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      props.setAccounts(accounts)
      console.log(accounts)
    }
  }
  
  return (
    <>
      <div id='home'></div>
        <div className='nav'>
          <div className='nav-container'>
            <ul className='full-screen-menu'>
              <li><Link smooth to='/#home'>Home</Link></li>
              <li><Link smooth to='/#collection'>Collection</Link></li>
              <li><Link smooth to='/#about'>About</Link></li>
              <li><Link to='/roadmap'>Roadmap</Link></li>
              <li><Link to='/social'>Social</Link></li>
            </ul>
            
            {/* for mobile */}
            <div className='burger'>
              <FaIcons.FaBars onClick={() => props.setMenu(true)}/>
            </div>          
            
            <ul className='nav-buttons'>
              <li><button onClick={() => {props.setModal(true)}}>Instructions</button></li>
              <li>{isConnected ? (<p>Wallet Connected</p>
              ) : (
                <button onClick={connectAccount}>Connect Wallet</button>
              )}
                </li>
            </ul>
          </div>
        </div>
    </>
  );
}

export default Nav;