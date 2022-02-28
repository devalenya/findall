pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";



contract NFTMarketPlace is ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public marketFees = 0.00001000 ether;
    uint256 public constant maxMint = 1;
    uint256 public MAX_TOKENS = 600;
    address payable owner;

      using Counters for Counters.Counter;
     Counters.Counter private itemId;
    Counters.Counter private itemsSold;

     constructor(){
         owner = payable(msg.sender);
     }
    

    struct NftMerketItem{
        address nftContract;
        uint256 id;
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool sold;


    }

        event NftMerketItemCreated(
        address  indexed nftContract,
        uint256 indexed id,
        uint256 tokenId,
        address  owner,
        address  seller,
        uint256 price,
        bool sold
        );
 

    
    function gettheMarketFees()public view returns(uint256){
        return marketFees;
    }
///////////////////////////////////
     mapping(uint256=>NftMerketItem) private idForMarketItem;
///////////////////////////////////
    function createItemForSale(address nftContract,uint256 tokenId,uint256 price)public payable {
        require(price >0,"Price should be moreThan 1");
        require(tokenId >0,"token Id should be moreThan 1");
        require(msg.value == marketFees,"The Market Fees is 1 BNB");
        require(nftContract != address(0),"address should be a BNB address");
        //Check that the number of tokens requested doesn't exceed the max. allowed.
        require(tokenId <= maxMint, "You can only mint 1 tokens at a time");
        // Check that the number of tokens requested wouldn't exceed what's left.
        require(totalSupply().add(tokenId) <= MAX_TOKENS, "Minting would exceed max. supply");
        // Check that the right amount of Ether was sent.
        require(marketFees.mul(tokenId) <= msg.value, "Not enough Ether sent.");

        // For each token requested, mint one.
        for(uint256 i = 0; i < tokenId; i++) {
            uint256 createItemForSaleIndex = totalSupply();
            if(createItemForSaleIndex < MAX_TOKENS) {
                /** 
                 * Mint token using inherited ERC721 function
                 * msg.sender is the wallet address of mint requester
                 * mintIndex is used for the tokenId (must be unique)
                 */
                _safeMint(msg.sender, createItemForSaleIndex);
            }
        }
        itemId.increment();
        uint256 id = itemId.current();

        idForMarketItem[id]= NftMerketItem(
            nftContract,
            id,
            tokenId,
            payable (address (0)),
            payable(msg.sender),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit NftMerketItemCreated(nftContract, id, tokenId, address(0), msg.sender, price, false);

    }
    //Create Maket

    function createMarketForSale(address nftContract,uint256 nftItemId) public payable nonReentrant {
     uint256 price = idForMarketItem[nftItemId].price;
     uint256 tokenId = idForMarketItem[nftItemId].tokenId;

     require(msg.value == price,"should buy the price of item");
      idForMarketItem[nftItemId].seller.transfer(msg.value);
      IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); //buy
      idForMarketItem[nftItemId].owner = payable(msg.sender);
      idForMarketItem[nftItemId].sold =  true;
      itemsSold.increment();
    payable(owner).transfer(marketFees);

    }

    //My items => sold,not sold,buy

function getMyItemCreated() public view returns(NftMerketItem[] memory){
uint256 totalItemCount = itemId.current(); 
uint myItemCount=0;//10
uint myCurrentIndex =0;

for(uint i = 0;i<totalItemCount;i++){
    if(idForMarketItem[i+1].seller == msg.sender){
        myItemCount+=1;

    }
}
NftMerketItem [] memory nftItems = new NftMerketItem[](myItemCount); //list[3]
for(uint i = 0;i<totalItemCount;i++){
    if(idForMarketItem[i+1].seller==msg.sender){      //[1,2,3,4,5]
      uint currentId = i+1;
        NftMerketItem storage  currentItem = idForMarketItem[currentId];
        nftItems[myCurrentIndex] = currentItem;
        myCurrentIndex +=1;
        
    }
}


return nftItems;

}


//Create My purchased Nft Item

function getMyNFTPurchased() public view returns(NftMerketItem[] memory){
uint256 totalItemCount = itemId.current(); 
uint myItemCount=0;//10
uint myCurrentIndex =0;

for(uint i = 0;i<totalItemCount;i++){
    if(idForMarketItem[i + 1 ].owner == msg.sender){
        myItemCount+=1;

    }
}

NftMerketItem [] memory nftItems = new NftMerketItem[](myItemCount); //list[3]
for(uint i = 0;i<totalItemCount;i++){
    if(idForMarketItem[i+1].owner== msg.sender){      //[1,2,3,4,5]
      uint currentId = i+1;
        NftMerketItem storage  currentItem = idForMarketItem[currentId];
        nftItems[myCurrentIndex] = currentItem;
        myCurrentIndex +=1;
        
    }
}


return nftItems;

}
//Fetch  all unsold nft items
function getAllUnsoldItems()public view returns (NftMerketItem[] memory){

uint256 totalItemCount = itemId.current(); 
uint myItemCount= itemId.current() - itemsSold.current();
uint myCurrentIndex =0;



NftMerketItem [] memory nftItems = new NftMerketItem[](myItemCount); //list[3]
for(uint i = 0;i<totalItemCount;i++){
    if(idForMarketItem[i+1].owner== address(0)){      //[1,2,3,4,5]
      uint currentId = i+1;
        NftMerketItem storage  currentItem = idForMarketItem[currentId];
        nftItems[myCurrentIndex] = currentItem;
        myCurrentIndex +=1;
        
    }
}


return nftItems;


}
}
