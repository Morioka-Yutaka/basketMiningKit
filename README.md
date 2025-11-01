# basketMiningKit
Performs Market Basket (Association Rule) Analysis  to efficiently compute 1-item and 2-item  co-occurrence frequencies and derive key association metrics.  

<img width="359" height="359" alt="Image" src="https://github.com/user-attachments/assets/b0a762a0-766b-4785-a079-88a61f8b25f5" />

## %association_rule_mining() macro  
  Purpose    : Performs Market Basket (Association Rule) Analysis   
                   to efficiently compute 1-item and 2-item  
                   co-occurrence frequencies and derive key association metrics.  

  ### Overview   :  
     The macro takes a transactional dataset (ID, ITEM) as input.
    - It counts single-item occurrences and two-item co-occurrences across unique transactions.
    - It outputs 1-item statistics and 2-item directional association rules
      (e.g., ITEM ==>ITEM2) with standard association metrics:
        * Support
        * Confidence
        * Lift
  
  ### Parameters :  
    inds=             Input dataset name (e.g., AE)
    person=           Transaction or subject identifier (e.g., USUBJID)
    item=             Item variable representing product/event (e.g., AEDECOD)
    itemset_length=   Length for character variable VECTOR (default: $500)
                      VECTOR is used to display the rule "ITEM --> ITEM2".

  ### Input  :  
    - Dataset &inds. containing at least the variables &person. and &item.  
    - The macro internally creates &inds._nodup as a unique (ID, ITEM) dataset  
      to avoid double-counting within the same transaction.  

  ### Output :  
    - Dataset: association_rule_mining  
      Variables:  
        VECTOR        : Display text for the rule (e.g., "Headache --> Nausea")  
        ITEM, ITEM2   : Left-hand and right-hand items  
        COUNT         : Frequency of the item or item-pair  
        SUPPORT       : Support value (frequency ratio)  
        CONFIDENCE    : Confidence value (conditional probability)  
        LIFT          : Lift value (measure of association strength)  

   ###  Usage Example :  
    %association_rule_mining(
      inds=AE,
      person=USUBJID,
      item=AEDECOD,
      itemset_length=$500
    );
    
    ### Association Metrics and Derivations
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
    
## Notes on versions history
- 0.1.0(02ONovember2025): Initial version.

---

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
