//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract LoanFi {
    address payable public lender;
    IERC20 immutable public token;
    constructor(IERC20 _token,address payable _lender) {
        token=_token;
        lender=_lender;
    }

            event LoanRequested(address indexed borrower,uint256 loanamount); 
            event LoanAccepted(address indexed lender,address indexed borrower,uint256 loanamount,uint256 duedate);     
            event LoanPaid(address indexed payer,uint256 time);
            event Possessed(address indexed lender,uint256 time,uint256 amount);
    struct Loan {
        uint256 loanid;
        address lender;
        address borrower;
        uint256 collateralamount;
        uint256 loanamount;
        uint256 payoffamount;
        uint256 loanduration;
        uint256 duedate;
        STATUS status;
    }
    mapping(address=>Loan) public loandetails;
    uint256 public loans;
    mapping(uint256=>address) public requestdetails;
    uint256 public loanrequests;
    uint256 internal loanid=1001;
    enum STATUS{REQUESTED,ACCEPTED}
    
    modifier Onlylender(){
        require(msg.sender==lender,"Not an Authorized User");
        _;
    }
    modifier CheckLoan(){
        require(loandetails[msg.sender].status!=STATUS.ACCEPTED,"Loan already exists");
        _;
    }
    function RequestLoan(IERC20 _token,uint256 _collateralamount,uint256 _loanamount,uint256 _payoffamount,uint256 _loanduration) public CheckLoan {
          _loanduration=_loanduration*1 days;
          require(token==IERC20(_token),"Invalid collateral token address");
          require(IERC20(_token).balanceOf(msg.sender)>=_collateralamount,"Insufficient Funds in your wallet");
          require(_loanduration<90 days,"loan duration must be less than 90 days");
          require(IERC20(_token).approve(lender,_collateralamount));
          _loanamount*=1 ether;
          
          loandetails[msg.sender]=Loan(0,address(0),msg.sender,_collateralamount,_loanamount,_payoffamount,_loanduration,0,STATUS.REQUESTED);
          requestdetails[loanrequests]=msg.sender;
          loanrequests++;
          emit LoanRequested(msg.sender,_loanamount);
    }
    function LoanStatus(address _borrower) public view returns(Loan memory) {
          return loandetails[_borrower];
    }  
    function lendEther(address _borrower) payable public Onlylender {
         require(msg.value==loandetails[_borrower].loanamount,"Enter Valid amount");
         uint256 _id = find(_borrower);
         loandetails[_borrower].loanid=loanid;
         loandetails[_borrower].lender=msg.sender;
         loandetails[_borrower].status=STATUS.ACCEPTED;
         loandetails[_borrower].duedate=block.timestamp+loandetails[_borrower].loanduration;
         loanid++;
         require(token.transferFrom(_borrower,lender,loandetails[_borrower].collateralamount));
         require(token.approve(_borrower,loandetails[_borrower].collateralamount));
         payable(_borrower).transfer(loandetails[_borrower].loanamount);
         delete requestdetails[_id];
         loanrequests--;
         emit LoanAccepted(msg.sender,_borrower,loandetails[_borrower].loanamount,loandetails[_borrower].duedate);
    }

    function find(address _addr) internal view returns(uint256) {
       for(uint256 i=0;i<loanrequests;i++){
         if(requestdetails[i]==_addr){
             return i;
         }
       }
    }
    
    function payLoan() public payable {
        require(block.timestamp <= loandetails[msg.sender].loanduration);
        require(msg.value == loandetails[msg.sender].payoffamount);
        lender.transfer(loandetails[msg.sender].payoffamount);
        require(token.transferFrom(lender,msg.sender,loandetails[msg.sender].collateralamount));
        emit LoanPaid(msg.sender,block.timestamp);
    }

     function repossess(address _borrower) public Onlylender {
        require(block.timestamp > loandetails[_borrower].loanduration);
        require(token.transfer(lender,loandetails[_borrower].collateralamount));
        emit Possessed(msg.sender,block.timestamp,loandetails[_borrower].collateralamount);
    }
}