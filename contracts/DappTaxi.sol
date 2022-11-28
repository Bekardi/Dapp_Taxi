pragma solidity >=0.4.22 <0.9.0;

//Anything that you declare inside the contract is gonna be deployed to the blockchain

// commads to run to start the project: 
// 1)npm install -g @remix-project/remixd
// 2) remixd -s .

contract DappTaxi {
   // address public owner = msg.sender; // person that has created this smartcontract (wallet address)

    //Ride booking
    struct Booking {
        address passengerAddress; //contract owner (wallet basically) 
        uint256 price;      
        string passengerInfo;   //passenger name
        address driverAddress;  //driver's  Wallet
        string driverInfo;      //driver's name
        string originLocation;  //A
        string destLocation;    //B

        string status; // new, cancelled, accepted, ontrip, completed
    }

    Booking[] public bookings; //public array of bookings

     // declare events
    event BookingCreated(uint256 bookingIndex);
    event BookingAccepted(uint256 bookingIndex);
    event BookingCompleted(uint256 bookingIndex);
    event BookingCancelled(uint256 bookingIndex);

    // passenger can create a booking
    function createBooking(
        string memory passengerInfo,
        string memory originLocation,
        string memory destLocation
    ) public payable {

        bookings.push(
            Booking(
                msg.sender,     // passengerAddress = person that has created this smartcontract (wallet address)
                msg.value,          // price 
                passengerInfo, 
                address(0x0),   //driverAddress (wallet)
                "",             //driverInfo
                originLocation,
                destLocation,
                "new"
            )
        );

        emit BookingCreated(bookings.length);
    }
 

    function getBooking(uint256 index)
        public
        view
        returns (
            address,
            uint256,
            string memory,
            address,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        Booking memory book = bookings[index];
        return (
            book.passengerAddress,
            book.price,
            book.passengerInfo,
            book.driverAddress,
            book.driverInfo,
            book.originLocation,
            book.destLocation,
            book.status
        );
    }

    function getBookingCount() public view returns (uint256) {
        return bookings.length;
    }

    // passenger can cancel booking, cost will be refund
    function cancelBooking(uint256 index) public {
        // validation
        require(
            msg.sender == bookings[index].passengerAddress &&
                compareStrings(bookings[index].status, "new") || 
                compareStrings(bookings[index].status, "ontrip"),
            "validation failed."
        );
 
        address payable passengerWallet = payable(bookings[index].passengerAddress); 
        passengerWallet.transfer(bookings[index].price);
        bookings[index].status = "cancelled";
        emit BookingCancelled(index);
    }

    // driver accepts booking created from passenger
    function acceptBooking(
        uint256 index, //booking Index
      //  address driverAddress,
        string memory driverInfo) 
        public  {
        // validation
        require(
            bookings[index].driverAddress == address(0x0) && 
                compareStrings(bookings[index].status, "new"),
            "validation failed."
        );
        bookings[index].driverAddress = msg.sender;
        bookings[index].driverInfo = driverInfo;
        bookings[index].status = "ontrip";
        emit BookingAccepted(index);
    }

    // passenger must to confirm trip completed
    function completeBooking(uint256 index) public {
        // // validation
        require (
            msg.sender == bookings[index].passengerAddress &&
                compareStrings(bookings[index].status, "ontrip"),
            "validation failed."
        );
        address payable driverWallet = payable(bookings[index].driverAddress); 
        driverWallet.transfer(bookings[index].price);
        bookings[index].status = "completed";
        emit BookingCompleted(index);
    }

    //function that we used for validation between 2 strings, mostly used to compare address on trip status 
    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return
                keccak256(abi.encodePacked(a)) ==
                keccak256(abi.encodePacked(b));
        }
    }
}
