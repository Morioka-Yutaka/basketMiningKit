# basketMiningKit
Performs Market Basket (Association Rule) Analysis  to efficiently compute 1-item and 2-item  co-occurrence frequencies and derive key association metrics.  

<img width="359" height="359" alt="Image" src="https://github.com/user-attachments/assets/b0a762a0-766b-4785-a079-88a61f8b25f5" />

## %association_rule_mining() macro  
  Purpose    : Performs Market Basket (Association Rule) Analysis   
                   to efficiently compute 1-item and 2-item  
                   co-occurrence frequencies and derive key association metrics.  

  Overview   :  
    - The macro takes a transactional dataset (ID, ITEM) as input.
    - It counts single-item occurrences and two-item co-occurrences
       across unique transactions.
    - It outputs 1-item statistics and 2-item directional association rules
      (e.g., ITEM ==>ITEM2) with standard association metrics:
        * Support
        * Confidence
        * Lift
  
  Parameters :  
  ~~~text
    inds=             Input dataset name (e.g., AE)
    person=           Transaction or subject identifier (e.g., USUBJID)
    item=             Item variable representing product/event (e.g., AEDECOD)
    itemset_length=   Length for character variable VECTOR (default: $500)
                      VECTOR is used to display the rule "ITEM --> ITEM2".
  ~~~
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

    Usage Example :  
    ~~~sas
    %association_rule_mining(
      inds=AE,
      person=USUBJID,
      item=AEDECOD,
      itemset_length=$500
    );
    ~~~
    
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
           CONFIDENCE(X=>Y) = P(Y | X)  
                            = count(X,Y) / count(X)  

    3) Lift (LIFT)  
       - The ratio of observed co-occurrence to independence expectation:  
           LIFT(X=>Y) = CONFIDENCE(X=>Y) / P(Y)  
                     = [count(X,Y) / count(X)] / [count(Y) / N]  
                     = (count(X,Y) * N) / [count(X) * count(Y)]  
  
       Interpretation:  
         LIFT > 1 : Positive association (X increases likelihood of Y)  
         LIFT = 1 : Independent relationship  
         LIFT < 1 : Negative association (X suppresses Y)  

    * 1-item rules output SUPPORT only (CONFIDENCE and LIFT are missing).  
