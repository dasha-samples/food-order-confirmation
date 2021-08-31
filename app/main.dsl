// Import the commonReactions library so that you don't have to worry about coding the pre-programmed replies
import "commonReactions/all.dsl";

context
{
// Declare the input variable - phone. It's your hotel room phone number and it will be used at the start of the conversation.  
    input phone: string;
// Storage variables. You'll be referring to them across the code. 
    appetizers: {[x:string]:string;}[] = [];
    drinks: {[x:string]:string;}[] = [];
    new_burger: {[x:string]:string;}[] = [];
    street: string="";
    house_num: string="";
    cash: string="";
    card: string="";
}

// A start node that always has to be written out. Here we declare actions to be performed in the node. 
start node root
{
    do
    {
        #connectSafe($phone); // Establishing a safe connection to the user's phone.
        #waitForSpeech(1000); // Waiting for 1 second to say the welcome message or to let the user say something
        #sayText("Hi, this is Dasha, I'm calling to verify some information regarding your order with ABC Burgers."); // Welcome message
        wait *; // Wating for the user to reply
    }
    transitions // Here you give directions to which nodes the conversation will go
    {
        next: goto order_confirmation_start on true;
    }
}

node order_confirmation_start
{
    do 
    {   
        #sayText("Yeah, hi, so I see that you've ordered a cheeseburger to be delivered to 78 Washington Road. Do you want to change anything about your order?"); 
        wait*;
    }
    transitions
    {
        payment_method: goto payment_method on #messageHasIntent("no");
        edit_new_order: goto edit_new_order on #messageHasIntent("yes");
    }
}

digression change_order_burger
{
    conditions {on #messageHasData("burger_kind");}
    do 
    {   
        var sentence = "Perfect. I've added ";
        set $new_burger = #messageGetData("burger_kind");
        for (var item in $new_burger) {
            set sentence = sentence + (item.value ?? " and ");
        }
        set sentence = sentence + " to your order. Would you like anything else?"; 
        #sayText(sentence); 
        wait *;
    }
    transitions
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("order_sth_else");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

node change_order_burger
{
        do 
    {   
        var sentence = "Perfect. I've added ";
        set $new_burger = #messageGetData("burger_kind");
        for (var item in $new_burger) {
            set sentence = sentence + (item.value ?? " and ");
        }
        set sentence = sentence + " to your order. Would you like anything else?"; 
        #sayText(sentence); 
        wait *;
    }
    transitions
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("order_sth_else");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

digression burgers_available
{
    conditions {on #messageHasIntent("burgers_available");}
    do 
    {
        #sayText("We've got cheeseburger, hawaiian burger, buffalo chicken burger, creamy mushroom burger, beef burger and barbeque burger. Which one would you like?"); 
        wait*;
    }
    transitions
    {
        change_order_burger: goto change_order_burger on #messageHasData("burger_kind");
    }
}

digression edit_new_order
{
    conditions {on #messageHasIntent("order_sth_else");}
    do
    {
        #sayText("What can I get for you?"); 
        wait *; 
    }
}

node nvm
{
        do
    {
        #sayText("Is there anything else I can help you with?"); 
        wait *;
    }
    transitions
    {
        payment_method: goto payment_method on #messageHasIntent("no");
        edit_new_order: goto edit_new_order on #messageHasIntent("yes");
    }
}

digression nvm
{
    conditions {on #messageHasIntent("nvm");}
    do
    {
        #sayText("Okay! How may I help you?"); 
        wait *; 
    }
}

node edit_new_order
{
    do
    {
        #sayText("What can I get for you?"); 
        wait *; 
    }
    transitions
    {

    }
}

digression different_address
{
    conditions {on #messageHasIntent("different_address");}
    do
    {
        #sayText("Sounds good, could you tell me the building number and the street name, please?"); 
        wait *; 
    }
}

digression change_street
{
    conditions {on #messageHasIntent("change_street");}
    do 
    {
        set $street = #messageGetData("street")[0]?.value??"";
        #sayText("Okay, I changed the street to " + $street + " . Is there anything else you'd like to change?"); 
        wait *;
    }
    transitions
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("order_sth_else");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

digression change_house_num
{
    conditions {on #messageHasIntent("change_house_num");}
    do 
    {
        set $house_num = #messageGetData("house_num")[0]?.value??"";
        #sayText("Gotcha, I changed the building number to " + $house_num + " . Is there anything else you'd like to change?"); 
        wait *;
    }
    transitions
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("order_sth_else");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

digression change_address
{
    conditions {on #messageHasData("house_num") and #messageHasData("street");}
    do 
    {
        set $street = #messageGetData("street")[0]?.value??"";
        set $house_num = #messageGetData("house_num")[0]?.value??"";
        #sayText("Okay, changed the delivery address to " + $house_num + " " + $street + ". Is there anything else you'd like to change?"); 
        wait *;
    }
    transitions
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("order_sth_else");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

digression appetizers
{
    conditions {on #messageHasIntent("appetizers");}
    do 
    {
        #sayText("We've got fried calamari, french fries, spring salad, and a soup of the day. What of these would you like to order?");
        wait *;
    }
    transitions 
    {
       confirm_appetizers: goto confirm_appetizers on #messageHasData("appetizers");
    }
     onexit
    {
        confirm_appetizers: do {
        set $appetizers =  #messageGetData("appetizers", { value: true });
       }
    }
}

digression drinks
{   
    conditions {on #messageHasIntent("drinks");}
    do 
    {
        #sayText("We have orange juice, Sprite, and vanilla milkshakes. What would you like to get?");
        wait *;
    }
    transitions 
    {
       confirm_drinks: goto confirm_drinks on #messageHasData("drinks");
    }
    onexit
    {
        confirm_drinks: do {
        set $drinks = #messageGetData("drinks", { value: true });
       }
    }
}

node confirm_drinks
{
    do
    {
        var sentence = "Noted, I added ";
        set $drinks = #messageGetData("drinks");
        for (var item in $drinks) {
            set sentence = sentence + (item.value ?? " and "); // In case the guest desides to order multiple items of food
        }
        set sentence = sentence + " to your order. Anything else you'd like to order?";
        #sayText(sentence); 
        wait *;
    }
     transitions 
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("appetizers");
        confirm_appetizers: goto confirm_appetizers on #messageHasData("appetizers");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

node confirm_appetizers
{
    do
    {
        var sentence = "Perfect. I've added ";
        set $appetizers = #messageGetData("appetizers");
        for (var item in $appetizers) {
            set sentence = sentence + (item.value ?? " and ");
        }
        set sentence = sentence + " to your order. Is there anything else you'd like?";
        #sayText(sentence); 
        wait *;
    }
     transitions 
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes") or #messageHasIntent("drinks");
        confirm_drinks: goto confirm_drinks on #messageHasData("drinks");
        review_full_order: goto review_full_order on #messageHasIntent("no");
    }
}

node review_full_order
{
    do
    {
        var sentence = "To review your order, you want to get ";
        for (var item in $new_burger) {
            set sentence = sentence + (item.value ?? "") + (", ");
        }
        for (var item in $appetizers) {
            set sentence = sentence + (item.value ?? "") + (", and ");
        }
        for (var item in $drinks) {
            set sentence = sentence + (item.value ?? "");
        }
        set sentence = sentence + ". Would you like anything else?"; 
        #sayText(sentence); 
        wait *;
    }
     transitions 
    {
        payment_method: goto payment_method on #messageHasIntent("no");
        edit_new_order: goto edit_new_order on #messageHasIntent("yes");
    }
}

node payment_method
{
    do
    {
        #sayText("Gotcha. Now, would you be paying with cash or by card?");
        wait *;
    }
     transitions 
    {
        with_cash: goto with_cash on #messageHasIntent("cash");
        by_card: goto by_card on #messageHasIntent("card");
    }
}

node with_cash
{
    do
    {
        #sayText("Sounds good, with cash it is. Your order will be ready in 15 minutes. Thank you for your order! Bye bye!");
        exit;
    }
}

node by_card
{
    do
    {
        #sayText("Sounds good, by card it is. Your order will be ready in 15 minutes. Thank you for your order! Bye bye!");
        exit;
    }
}

digression cancel_order
{   
    conditions {on #messageHasIntent("cancel_order");}
    do 
    {
        #sayText("Okay, just cancelled your order. Is there anything else I can help you with?");
        wait *;
    }
    transitions 
    {
        edit_new_order: goto edit_new_order on #messageHasIntent("yes");
        bye: goto bye on #messageHasIntent("no");
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye"); }
    do 
    {
        #sayText("Thanks for your time. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}

node bye 
{
    do 
    {
        #sayText("Thanks for your time. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}
