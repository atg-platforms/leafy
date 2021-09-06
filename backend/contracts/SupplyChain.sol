pragma solidity >=0.4.21 <0.6.0;

contract supplyChain {
    uint32 public product_id = 0;   // Product ID
    uint32 public participant_id = 0;   // Participant ID
    uint32 public owner_id = 0;   // Ownership ID

    struct product {
        string plantType;
        uint32 farmerId;
        address productOwner;
        uint32 unitCost;
        uint32 farmTimeStamp;
    }

    mapping(uint32 => product) public products; // products by product_id

    struct participant {
        string participantType;
        address participantAddress;
    }

    mapping(uint32 => participant) public participants; // participants by participant_id

    struct ownership {
        uint32 productId;
        uint32 ownerId;
        uint32 trxTimeStamp;
        address productOwner;
    }
    mapping(uint32 => ownership) public ownerships; // ownerships by ownership_id (owner_id)
    mapping(uint32 => uint32[]) public productTrack;  // ownerships by product_id (product_id) / Movement track for a product

    event TransferOwnership(uint32 indexed productId);

    function addParticipant(address _pAdd, string memory _pType) public returns (uint32){
        uint32 userId = participant_id++;
        participants[userId].participantAddress = _pAdd;
        participants[userId].participantType = _pType;

        return userId;
    }

    function getParticipant(uint32 _participant_id) public view returns (address,string memory) {
        return (participants[_participant_id].participantAddress,
                participants[_participant_id].participantType);
    }

    function addProduct(uint32 _ownerId,
                        string memory _plantType,
                        uint32 _unitCost) public returns (uint32) {
        if(keccak256(abi.encodePacked(participants[_ownerId].participantType)) == keccak256("Farmer")) {
            uint32 productId = product_id++;

            //initial ownership
            uint32 ownership_id = owner_id++;
            ownerships[ownership_id].productId = productId;
            ownerships[ownership_id].productOwner = participants[_ownerId].participantAddress;
            ownerships[ownership_id].ownerId = _ownerId;
            ownerships[ownership_id].trxTimeStamp = uint32(now);
            productTrack[productId].push(ownership_id);

            //create product
            products[productId].plantType = _plantType;
            products[productId].unitCost = _unitCost;
            products[productId].productOwner = participants[_ownerId].participantAddress;
            products[productId].farmerId = _ownerId;
            products[productId].farmTimeStamp = uint32(now);
            return productId;
        }

       return 0;
    }

    // require that only current product owner is doing transaction
    //??
    modifier onlyOwner(uint32 _productId) {
         require(msg.sender == products[_productId].productOwner,"");
         _;
    }

    // return true if transferring from Farmer to Consumer
    // else return false

    function newOwner(uint32 _user1Id,uint32 _user2Id, uint32 _prodId) onlyOwner(_prodId) public returns (bool) {
        participant memory p1 = participants[_user1Id];
        participant memory p2 = participants[_user2Id];
        uint32 ownership_id = owner_id++;

        if(keccak256(abi.encodePacked(p1.participantType)) == keccak256("Farmer")
            && keccak256(abi.encodePacked(p2.participantType))==keccak256("Consumer")){
                ownerships[ownership_id].productId = _prodId;
                ownerships[ownership_id].productOwner = p2.participantAddress;
                ownerships[ownership_id].ownerId = _user2Id;
                ownerships[ownership_id].trxTimeStamp = uint32(now);
                products[_prodId].productOwner = p2.participantAddress;
                productTrack[_prodId].push(ownership_id);
                emit TransferOwnership(_prodId);

                return (true);
        }

        return (false);
    }

    function getProductDetails(uint32 _productId) public view returns (string memory,uint32,address,uint32,uint32){
        return (products[_productId].plantType,
                products[_productId].farmerId,
                products[_productId].productOwner,
                products[_productId].unitCost,
                products[_productId].farmTimeStamp);
    }

    //return list of ownership ids representing movement for a product 
    function getProvenance(uint32 _prodId) external view returns (uint32[] memory) {
       return productTrack[_prodId];
    }

    //return details of ownershipId
    function getOwnershipDetails(uint32 _regId)  public view returns (uint32,uint32,address,uint32) {
        ownership memory r = ownerships[_regId];
        return (r.productId,r.ownerId,r.productOwner,r.trxTimeStamp);
    }

}