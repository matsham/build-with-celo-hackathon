// SPDX-License-Identifier: MIT
import "PPA.sol";
import "PSA.sol";

pragma solidity >=0.7.0 <0.9.0;

/*interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721Token {  //Check for correct functions in the 721 interface
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}*/

contract EnergyMarket () {
    using Counters for Counters.Counter;

    Counters.Counter  private _OfferIds;                 //Counts offers
    Counters.Counter  private _InstallerIds;             //Counts Installers
    Counters.Counter  private _GeneratorIds;             // Counts Generators
    Counters.Counter  private _GeneratorIds;             // Count
    //Counters.Counter  private _MPPAsMade;              //Counts the number of agreed MPPAs
    //Counters.Counter  private _MPPAsRunning;           //Counts the number of running MPPAs
    Counters.Counter  private _ConsumerIds;             //Counts the number of running MPPAs
    

    uint public listingPrice;
    address Owner;
    
    mapping (uint => Offer) public Offers;                          //maps an unsigned integer to each offer 
    mapping (uint => installer) public installers;                  //maps an unsigned integer to each installer
    mapping (uint => EnergyProvider) public EnergyProviders;        //maps an unsigned integer to each installer
    mapping (uint => consumer) public consumers;                    //maps an unsigned integer to each installer
    mapping (address => bool) public ConsumerVerification;          //maps an unsigned integer to each installer
      
    struct installer{
        address payable InstallerAddress;
        string name;                                     //name of the installer
        string location;                                 //location of installing agent
        string installation_type;                        //Type of installation either
        uint NOI;                                        // NOI are number of installations
        uint Fee;                                        //fee for installation
        bool licensed;                                   //Licensing Boolean
    }

    struct EnergyProvider {
        address payable EPAddress;
        string name;                                     //name of the installer
        string location;
        bool licensed; 
        string Generation_Equipment;
        uint GenCap;
    }
    
     
    struct Offer {      
        string EPName;                                    //name of provider
        string ECPName;                                   //Name of Capacity Provider                               
        string location;                                  //Location
        address payable EP;                               //EP is the energy provider
        address payable ECP                               / ECP is equipment provider                                 
        uint8 public CapFee;                              //Capacity Fee
        uint8 public price;                               
        uint public Units;

    } 

    struct Consumer {
        address public payable ConsumerAddress;
        string public name;
        string public location;
        bool public verified;

    }




    constructor () public {
        Owner = msg.sender;
    }
    
    //Events
    event NewConsumerAdded (
        string ConsumerName,
        address _consumeraddress 
    )

    event NewInstallerAdded (
        string name,  
        string location,                                //location of installing agent
        string installation_type, 
        uint NOI                                 //name of the installer
    )

    event Sale (
        uint PPAId,
        uint PSAId,
        string EnergyConsumer,
        string EP,
        string ECP

    )

    event offerCreated (
        string EPName,                                   //name of provider
        string ECPName,                                //Name of Capacity Provider                               
        string location,
        uint price,                                //Location
        uint CapFee
    )

    event GenerationLicense  (
        address _generator,
        string _name,
        string _location,
        string Generation_Equipment
    )
    
    event InstallationLicense (
        address _installer,
        string _name
    )

    event ConsumerVerified (
        string ConsumerName,
        address Verified_Consumer
    )

    event changedListingPrice (
        uint NewlistingPrice
    )

    //MODIFIERS
    //Modifier for functions only the owner can call 
    modifier onlyOwner (uint _index) {
        require (require msg.sender == Owner);
        _;
    }
    
    // Modifier for functions only licensed installers can call
    modifier onlyLicensedInstaller (uint _index) {
        require (installers[_index].licensed);
        _;
    }
    
    // Modifier for functions only verified consumer can call
    modifier is_Verified_Consumer (uint _Cindex, address _ConsumertoVerify) {
        require (consumers[_Cindex].verified , "You can not call this transaction");
        require(ConsumerVerification[address _ConsumertoVerify] , "You can not call this transaction");
        _;
    }

    // Modifier for functions only Licensed Energy Providers can call
    modifier onlyLicensedEP (uint _Eindex) {
        require(EnergyProviders[_Eindex].licensed, "You arent a Licensed Energy Provider");
        _;
    }

    //FUNCTIONS
    // function to set listing price
    function setListingPrice (uint _listprice) private onlyOwner{
        listingPrice = _listprice;
        emit changedListingPrice(_listprice);
    }
    
    // function to license installers
    function Licenseinstaller (uint _index) onlyOwner {
        installers[_index].licensed = true;
        emit InstallationLicense(installers[_index].name , installers[_index].InstallerAddress);
    }

    //Function to verify which consumers can call transactions
    function verifyConsumer (uint _index, address _ConsumertoVerify) public onlyOwner {
        require (!consumers[_index].verified);
        require(!ConsumerVerification[address _ConsumertoVerify])
        consumers[_index].verified = true;
        ConsumerVerification[address _ConsumertoVerify] = true;

        emit ConsumerVerified (consumers[_index].name, consumers[_index].ConsumerAddress);
    } 

    function LicenseEP () public onlyOwner {
        require(!EnergyProviders[_Eindex].licensed, "This generator already licensed"); 
        EnergyProviders[_Eindex].licensed = true;

    }

    // function to Add new consumer to the network 
    function AddConsumer (
        string public _consumername,
        string public _consumerlocation,
        ) public {
        _ConsumerIds.increment() ; 
        consumers[_ConsumerIds] = consumer (
            payable(msg.sender),
            _consumername,
            _consumerlocation
        );  

       

        emit NewConsumerAdded (
            _ConsumerName,
            msg.sender 
        );
    }

    //Function only licensed installers
    function addInstallationAgent (
        string calldata _name,
        string calldata _location,
        string calldata _installation_type,
        uint _NOI,
        uint _Fee
    ) public {
       installers[_InstallerIds] = installer(
           _name,
           _location,
           _installation_type,
           _NOI,
           _Fee
       );
       installers[_InstallerIds].licensed = false;
       emit NewInstallerAdded(
           _name
           _location,                                //location of installing agent
           _installation_type, 
           _NOI                                 //name of the installer
    )

       );
    }
    
    // function to create offers on the market place
    function CreateOffer   (
        string calldata _EPName,
        string calldata ECPName,
        string calldata _description,
        string calldata _location,
        address payable  ECP
        uint _price,
        uint _Capfee

    ) public payable is_Verified_EP {
        require (price != 0, "Price can not be zero");
        address(this).transfer(listingPrice);
        _OfferId = _OfferIds
        _OfferIds.increment();
        
        Offers[_OfferId] = Offer(
            _name,
            _decription,
            _location,
            payable(msg.sender),
             ECP,
            _Capfee,
            _price
        );

        emit offerCreated (
            _EPName,                                   //name of provider
             ECPName,                                //Name of Capacity Provider                               
            _location,
            _price,                                //Location
            _CapFee
        )
    }

    // Function for consumers to initiate a Power Purchase
    function CreateSale (
        uint _ConsumerId,
        uint _Amount,
        uint _offerId
    ) public is_Verified_Consumer {
        require(ConsumerVerification[msg.sender], "You are not authorized to execute this transaction");
        require(consumers[_ConsumerId].verified, "You are not authorized to create a market sale");
        require(_Amount == (offers[_offerId].price + CapFee ) , "Money not enough");
        
        (bool PP, ) = payable(CNames[_tokenId].owner).call{
            value: offers[_offerId].price
        }("");
        
        
        (bool PCF, ) = payable(CNames[_tokenId].owner).call{
            value: offers[_offerId].CapFee;
        }("");


        if (PP & PCF) emit Paid (
            offers[_offerId].EPName,
            offers[_offerId].price,
            offers[_offerId].CapFee
        )

        
        createPPA (
            _ConsumerId,
            offers[_offerId].EPName,
            offers[_offerId].price,
            offers[_offerId].CapFee

        createPSA(
            _ConsumerId,
            offers[_offerId].EPName,
            offers[_offerId].price,
            offers[_offerId].CapFee,
        )
        /*require(
		IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
			Cars[_index].Dealer,1
			Cars[_index].price
		   ),
		  "Transfer failed."
		);
        require(
		  IERC20Token(cUsdTokenAddress).transferFrom(
			msg.sender,
			Cars[_index].Dealer,
			Cars[_index].price
		   ),
		  "Transfer failed."
		);*/
        emit Sale(
            _PPAIds.current()
        );
        //PPAs and PSA created in this function.
    }
}