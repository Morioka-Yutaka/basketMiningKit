/*** HELP START ***//*

Macro Name : association_rule_mining
  Purpose    : Performs Market Basket (Association Rule) Analysis 
                   to efficiently compute 1-item and 2-item
                   co-occurrence frequencies and derive key association metrics.

  Overview   :
    - The macro takes a transactional dataset (ID, ITEM) as input.
    - It counts single-item occurrences and two-item co-occurrences
       across unique transactions.
    - It outputs 1-item statistics and 2-item directional association rules
      (e.g., ITEM → ITEM2) with standard association metrics:
        * Support
        * Confidence
        * Lift

  Parameters :
    inds=             Input dataset name (e.g., AE)
    person=           Transaction or subject identifier (e.g., USUBJID)
    item=             Item variable representing product/event (e.g., AEDECOD)
    itemset_length=   Length for character variable VECTOR (default: $500)
                      VECTOR is used to display the rule "ITEM --> ITEM2".

  Input  :
    - Dataset &inds. containing at least the variables &person. and &item.
    - The macro internally creates &inds._nodup as a unique (ID, ITEM) dataset
      to avoid double-counting within the same transaction.

  Output :
    - Dataset: association_rule_mining
      Variables:
        VECTOR        : Display text for the rule (e.g., "Headache --> Nausea")
        ITEM, ITEM2   : Left-hand and right-hand items
        COUNT         : Frequency of the item or item-pair
        SUPPORT       : Support value (frequency ratio)
        CONFIDENCE    : Confidence value (conditional probability)
        LIFT          : Lift value (measure of association strength)

 Useage  Example :
    %association_rule_mining(
      inds=AE,
      person=USUBJID,
      item=AEDECOD,
      itemset_length=$500
    );
  ---------------------------------------------------------------------------
  Association Metrics and Derivations
  ---------------------------------------------------------------------------

    Let:
      N           = Total number of unique transactions (distinct IDs)
      count(X)    = Number of transactions containing item X
      count(X,Y)  = Number of transactions containing both X and Y
      P(A)        = Probability of event A = count(A) / N

    1) Support (SUPPORT)
       - The proportion of transactions containing the item(s):
           SUPPORT(X,Y) = count(X,Y) / N
           SUPPORT(X)   = count(X) / N

    2) Confidence (CONFIDENCE)
       - The conditional probability of Y given X:
           CONFIDENCE(X→Y) = P(Y | X)
                            = count(X,Y) / count(X)

    3) Lift (LIFT)
       - The ratio of observed co-occurrence to independence expectation:
           LIFT(X→Y) = CONFIDENCE(X→Y) / P(Y)
                     = [count(X,Y) / count(X)] / [count(Y) / N]
                     = (count(X,Y) * N) / [count(X) * count(Y)]

       Interpretation:
         LIFT > 1 : Positive association (X increases likelihood of Y)
         LIFT = 1 : Independent relationship
         LIFT < 1 : Negative association (X suppresses Y)

    * 1-item rules output SUPPORT only (CONFIDENCE and LIFT are missing).

*//*** HELP END ***/

%macro association_rule_mining(inds= AE, person = USUBJID, item=AEDECOD, itemset_length=$500);

proc sql noprint;
	select count(distinct &person.) into : sobs
	from &inds;
quit;

proc sort data=&inds.(keep=&person. &item.)  out = &inds._nodup nodupkey;
 by &person. &item.;
run;

data association_rule_mining;
length VECTOR &itemset_length.;
 informat VECTOR ITEM ITEM2  COUNT1 COUNT2  COUNT SUPPORT CONFIDENCE LIFT;

 if _N_=1 then  do;

  	declare hash h2 (suminc:'COUNT2');
  	declare hiter hi2 ('h2');
   	h2.defineKey ('ITEM','ITEM2');
   	h2.definedata('ITEM','ITEM2', 'COUNT2');
   	h2.defineDone ();

  	declare hash h1 (suminc:'COUNT1');
  	declare hiter hi1 ('h1');
   	h1.defineKey ('ITEM');
   	h1.definedata('ITEM','COUNT1');
   	h1.defineDone ();
 end;

 do while(^FL);
	set &inds._nodup(rename=(&item. = ITEM &person. = ID)) end = FL;
  	COUNT1 = 1;
  	h1.ref();

	 do i=1 to tobs;
	  set &inds._nodup( rename = (&person. = _ID &item. = ITEM2) ) point = i nobs = tobs ;
	   if ID = _ID and ITEM ne ITEM2 then do; 
	      COUNT2 = 1;
	      h2.ref(); 
	    end;
	  end;
end;

   do rc = hi2.first() by 0 while (rc = 0);
      LEVEL = 2 ;
      VECTOR = catx(" --> ", ITEM  , ITEM2 );
      h2.sum(sum : COUNT2);
      SUPPORT = COUNT2 / &sobs;      
      h1.sum(sum : COUNT1);
      CONFIDENCE = COUNT2 / COUNT1;   
	    h1.sum(key : ITEM2 , sum : _COUNT1);
      _SUPPORT = _COUNT1 / &sobs;     
      LIFT = CONFIDENCE/_SUPPORT;    
	    COUNT = COUNT2;
     output;
      rc=hi2.next();
   end;

   do rc=hi1.first() by 0 while (rc = 0);
      LEVEL = 1 ;
      VECTOR = cats( ITEM );
      call missing(ITEM2);
      h1.sum(sum: COUNT1);
      SUPPORT = COUNT1 / &sobs;          
	    COUNT = COUNT1;
      call missing( CONFIDENCE , LIFT);
     output;
      rc=hi1.next();
    end;

stop;
keep VECTOR ITEM ITEM2 SUPPORT COUNT CONFIDENCE LIFT;
run;


proc sort data=association_rule_mining ;
 by descending COUNT;
run;

%mend;
