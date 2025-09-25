/*
    Create a Simple DAO contract that allows user to vote yes or no
    The SimpleDao struct is the main storage of the contract.
    It contains:
    - queryId: uint32
    - yesVotes: uint32
    - noVotes: uint32
    - totalVotes: uint32

    The contract has 2 functionalities :
    - Record a vote
    - Reset the votes
    The contract has a yesVotes that is used to identify the yes votes.
    The contract has a noVotes that is used to identify the no votes.
    The contract has a totalVotes that is used to identify the total votes.

    There will be 2 structs :
    - RecordVote : This struct is used to record a vote.
    - ResetVotes : This struct is used to reset the votes.

    The struct definitions are :
    - RecordVote(queryId: uint32, vote: bool) : 0xF4A2B1C9
    - ResetVotes(queryId: uint32) : 0xD4E7B328

    There will be 1 getter function :
    - getVotes : This function is used to get the votes. (yesVotes, noVotes, totalVotes)

    Helpful Blueprint sdk commands:
    - npx blueprint build - To build the contract
    - npx blueprint test tests/SimpleDao.spec.ts - To test the contract
*/

tolk 1.1

struct SimpleDao {
    queryId: uint32;
    yesVotes: uint32;
    noVotes: uint32;
    totalVotes: uint32;
}

struct(0xF4A2B1C9) RecordVote {
    queryId: uint32;
    vote: bool; // true for yes, false for no
}

struct(0xD4E7B328) ResetVotes {
    queryId: uint32;
}

fun SimpleDao.load():SimpleDao {
    return SimpleDao.fromCell(contract.getData());
}

fun SimpleDao.save(self) {
    contract.setData(self.toCell());
}

type AllowedMessages = RecordVote | ResetVotes;

fun onInternalMessage(in: InMessage) {
    val msg = lazy AllowedMessages.fromSlice(in.body);

    match(msg){
        RecordVote => {
            var s: SimpleDao = lazy SimpleDao.load();
            /*if (s.queryId >= msg.queryId) {
                // Ignore old or duplicate messages
                return;
            }*/
            s.queryId = msg.queryId;
            if (msg.vote) {
                s.yesVotes = s.yesVotes + 1;
            } else {
                s.noVotes = s.noVotes + 1;
            }
            s.totalVotes = s.totalVotes + 1;
            SimpleDao.save(s);
        },
        ResetVotes => {
            var s: SimpleDao = lazy SimpleDao.load();
            /*if (s.queryId >= msg.queryId) {
                // Ignore old or duplicate messages
                return;
            }*/
            s.queryId = msg.queryId;
            s.yesVotes = 0;
            s.noVotes = 0;
            s.totalVotes = 0;
            SimpleDao.save(s);
        }
        else => {
            // Ignore unknown messages
            return;
        }
    }
}

get fun getVotes(): (uint32, uint32, uint32) {
    var s: SimpleDao = lazy SimpleDao.load();
    return (s.yesVotes, s.noVotes, s.totalVotes);
}

/*
get fun yesvotes(): uint32 {
    var s: SimpleDao = lazy SimpleDao.load();
    return s.yesVotes
}

get fun novotes(): uint32 {
    var s: SimpleDao = lazy SimpleDao.load();
    return s.noVotes
}

get fun totalvotes(): uint32 {
    var s: SimpleDao = lazy SimpleDao.load();
    return s.totalVotes
}
*/