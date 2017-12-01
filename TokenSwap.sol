pragma solidity ^0.4.15;

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);

  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

contract ERC223_channel_manager
{
    event ChannelOpened(uint8 indexed _id, address indexed _contract, bytes32 _secret);
    event ChannelConnected(uint8 indexed _id, address indexed _contract, bytes32 _secret);
    
    function openChannel(address _redeemer,
                         address _token,
                         address _desired_token,
                         uint256 _end_time,
                         uint256 _delay,
                         bytes32 _secret,
                         uint8 _id,
                         bool _open)
    {
        address _contract = new ERC223_swap_channel(_redeemer, _token, _desired_token, msg.sender, _end_time, _delay, _secret, _id);
        if(_open)
        {
            ChannelOpened(_id, _contract, _secret);
        }
        else
        {
            ChannelConnected(_id, _contract, _secret);
        }
    }
}
 
 contract ERC223_swap_channel {
     
     uint8 public channel_id;
     
     address public redeemer;
     address public token;
     address public desired_token;
     address public placer;
     uint256 public end_time;
     uint256 public delay; 
     bytes32 public secret;
     
     function ERC223_swap_channel(address _redeemer,
                                  address _token,
                                  address _desired_token,
                                  address _placer,
                                  uint256 _end_time,
                                  uint256 _delay,
                                  bytes32 _secret,
                                  uint8   _id)
     {
         redeemer      = _redeemer;
         token         = _token;
         desired_token = _desired_token;
         placer        = _placer;
         end_time      = _end_time;
         delay         = _delay;
         secret        = _secret;
         channel_id    = _id;
     }
     
     function tokenFallback(address _from, uint256 _amount, bytes _data)
     {
        require(msg.sender == token);
     }
     
     function redeem(string _secret)
     {
        if(msg.sender == redeemer && sha3(_secret) == secret && now < end_time)
        {
            ERC223(token).transfer(msg.sender, ERC223(token).balanceOf(this));
        }
     }
     
     function withdraw()
     {
        if(msg.sender == placer && now > (end_time + delay))
        {
            ERC223(token).transfer(msg.sender, ERC223(token).balanceOf(this));
        }
     }
 }
