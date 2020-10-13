# bbbq_1_fast

Branch |[![Travis CI logo](pics/TravisCI.png)](https://travis-ci.org)                                                                             |[![Codecov logo](pics/Codecov.png)](https://www.codecov.io)
-------|------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------
master |[![Build Status](https://travis-ci.org/richelbilderbeek/bbbq_1_fast.svg?branch=master)](https://travis-ci.org/richelbilderbeek/bbbq_1_fast) |[![codecov.io](https://codecov.io/github/richelbilderbeek/bbbq_1_fast/coverage.svg?branch=master)](https://codecov.io/github/richelbilderbeek/bbbq_1_fast/branch/master)
develop|[![Build Status](https://travis-ci.org/richelbilderbeek/bbbq_1_fast.svg?branch=develop)](https://travis-ci.org/richelbilderbeek/bbbq_1_fast)|[![codecov.io](https://codecov.io/github/richelbilderbeek/bbbq_1_fast/coverage.svg?branch=develop)](https://codecov.io/github/richelbilderbeek/bbbq_1_fast/branch/develop)

The first sub-question of the Bianchi, Bilderbeek and Bogaart Question.

 * :lock: [Full article](https://github.com/richelbilderbeek/bbbq_article)

## Workflow

  1. (optional) `make use_test_proteomes`
  2. `make peregrine` (on Peregrine or local)
  3. `make results` (on Peregrine or local)
  4. `make figures` (locally)

## File structure

I've separated this regarding the two `make` calls.


### 1. `make peregrine`

Run this on Peregrine.

Creates all:

 * `[target]_[haplotype_id]_ic50s.csv`
 * `[target]_topology.csv`

#### `haplotypes_lut.csv`

`haplotype`  |`haplotype_id`|`mhc_class`
-------------|--------------|-----------
HLA-A*01:01  |h1            |1
HLA-A*02:01  |h2            |1
...          |...           |...
HLA-DRB3*0101|h14           |2
HLA-DRB3*0202|h15           |2

```
Rscript create_haplotypes_lut.R
```

#### `[target].fasta`

The proteome

```
> Somethingine
AAACCCVVVVAAACCCVVVVAAACCCVVVVAAACCCVVVV
> Somethingase
AAACCCVVVVAAACCCVVVVAAACCC
```

```
Rscript get_proteome.R covid
Rscript get_proteome.R human
```

#### `[target]_proteins_lut.csv`

`protein_id`|`protein`     |`sequence`
------------|--------------|----------------------------------------
p1          |Somethingine  |AAACCCVVVVAAACCCVVVVAAACCCVVVVAAACCCVVVV
p2          |Somethingase  |AAACCCVVVVAAACCCVVVVAAACCC

```
Rscript create_proteins_lut.R covid
Rscript create_proteins_lut.R human
Rscript create_proteins_lut.R myco
```


### `[target]_[haplotype_id]_counts.csv`

`haplotype_id`|`protein_id`|`n_binders`|`n_binders_tmh`|`n_spots`|`n_spots_tmh`
--------------|------------|-----------|---------------|---------|-------------
h1            |p1          |11         |5              |100      |20
h1            |p2          |12         |4              |10       |2

Note that `n_spots` and `n_spots_tmh` can vary, 
due to MHC class-dependent epitope lengths.

```
Rscript create_all_counts_per_proteome.R
```

Calls:

 * Locally: `Rscript create_counts_per_proteome.R [args]`
 * On Peregine: `sbatch ../../peregrine/scripts/run_r_script.sh create_counts_per_proteome.R [args]`

```
[call] create_counts_per_proteome.R covid h1
[call] create_counts_per_proteome.R covid h2
...
[call] create_counts_per_proteome.R covid h1
[call] create_counts_per_proteome.R covid h2
...
[call] create_counts_per_proteome.R myco h1
[call] create_counts_per_proteome.R myco h2
```

### 2. `make results`

Run this after `make peregrine`

### `counts.csv`

`target`|`haplotype_id`|`protein_id`|`n_binders`|`n_binders_tmh`|`n_spots`|`n_spots_tmh`
--------|--------------|------------|-----------|---------------|---------|-------------
covid   |h1            |p1          |11         |5              |100      |20
covid   |h1            |p2          |12         |6              |101      |20


```
Rscript merge_all_counts.R
```

### `table_tmh_binders_mhc[mhc_class].csv`

Pretty-printed version

`haplotype`|`covid`      |`human`
-----------|-------------|-------------
HLA-A*01:01| 38.46 (5/13)| 25.00 (5/20)
HLA-B*39:01| 100.00 (2/2)|58.33 (14/24)
HLA-B*40:02|  55.56 (5/9)| 29.17 (7/24)

```
Rscript create_table_tmh_binders_mhc.R mhc1
Rscript create_table_tmh_binders_mhc.R mhc2
```

## Sim info

### 1k sequences, 10 GB

```
run_r_script_14196266.log:Used walltime       : 00:02:38
run_r_script_14196267.log:Used walltime       : 00:01:27
run_r_script_14196270.log:Used walltime       : 00:02:37
run_r_script_14196261.log:Used walltime       : 00:07:04
run_r_script_14196260.log:Used walltime       : 00:02:48
run_r_script_14196250.log:Used walltime       : 00:02:37
run_r_script_14196252.log:Used walltime       : 00:15:42
run_r_script_14196271.log:Used walltime       : 00:02:47
run_r_script_14196264.log:Used walltime       : 00:04:01
run_r_script_14196259.log:Used walltime       : 00:03:04
run_r_script_14196268.log:Used walltime       : 00:02:38
run_r_script_14196255.log:Used walltime       : 00:03:21
run_r_script_14196254.log:Used walltime       : 00:04:21
run_r_script_14196258.log:Used walltime       : 00:02:54
run_r_script_14196263.log:Used walltime       : 00:04:13
run_r_script_14196253.log:Used walltime       : 00:04:59
run_r_script_14196218.log:Used walltime       : 00:01:40
run_r_script_14196269.log:Used walltime       : 00:02:40
run_r_script_14196262.log:Used walltime       : 00:05:17
run_r_script_14196256.log:Used walltime       : 00:02:59
run_r_script_14196251.log:Used walltime       : 00:03:58
run_r_script_14196257.log:Used walltime       : 00:03:39
run_r_script_14196265.log:Used walltime       : 00:03:05
```

### 2k sequences, 10 GB

```
run_r_script_14706847.log:Used walltime       : 00:14:28
run_r_script_14706856.log:Used walltime       : 00:11:01
run_r_script_14706845.log:Used walltime       : 00:08:47
run_r_script_14706862.log:Used walltime       : 00:02:21
run_r_script_14706853.log:Used walltime       : 00:03:04
run_r_script_14706863.log:Used walltime       : 00:04:52
run_r_script_14706854.log:Used walltime       : 00:01:46
run_r_script_14706866.log:Used walltime       : 00:04:13
run_r_script_14706852.log:Used walltime       : 00:02:25
run_r_script_14706861.log:Used walltime       : 00:03:37
run_r_script_14706851.log:Used walltime       : 00:05:26
run_r_script_14706865.log:Used walltime       : 00:02:39
run_r_script_14706859.log:Used walltime       : 00:06:34
run_r_script_14706858.log:Used walltime       : 00:06:25
run_r_script_14706844.log:Used walltime       : 00:05:43
run_r_script_14706849.log:Used walltime       : 00:04:04
run_r_script_14706860.log:Used walltime       : 00:07:27
run_r_script_14706850.log:Used walltime       : 00:02:31
run_r_script_14706846.log:Used walltime       : 00:40:41
run_r_script_14706855.log:Used walltime       : 00:14:41
run_r_script_14706864.log:Used walltime       : 00:02:29
run_r_script_14706848.log:Used walltime       : 00:07:55
run_r_script_14706833.log:Used walltime       : 00:01:34
```

```
richel@N141CU:~/Downloads$ egrep -R "Max Mem" --include=*.log
run_r_script_14706846.log:Max Mem used        : 3.25G (pg-node276)
run_r_script_14706856.log:Max Mem used        : 2.60G (pg-node275)
run_r_script_14706864.log:Max Mem used        : 1.83G (pg-node275)
run_r_script_14706858.log:Max Mem used        : 2.05G (pg-node275)
run_r_script_14706865.log:Max Mem used        : 1.86G (pg-node275)
run_r_script_14706844.log:Max Mem used        : 1.96G (pg-node276)
run_r_script_14706853.log:Max Mem used        : 1.97G (pg-node276)
run_r_script_14706847.log:Max Mem used        : 2.36G (pg-node276)
run_r_script_14706851.log:Max Mem used        : 1.97G (pg-node276)
run_r_script_14706861.log:Max Mem used        : 1.86G (pg-node275)
run_r_script_14706850.log:Max Mem used        : 1.87G (pg-node276)
run_r_script_14706860.log:Max Mem used        : 2.01G (pg-node275)
run_r_script_14706866.log:Max Mem used        : 1.96G (pg-node275)
run_r_script_14706863.log:Max Mem used        : 1.99G (pg-node275)
run_r_script_14706848.log:Max Mem used        : 2.08G (pg-node276)
run_r_script_14706845.log:Max Mem used        : 2.12G (pg-node276)
run_r_script_14706862.log:Max Mem used        : 1.83G (pg-node275)
run_r_script_14706859.log:Max Mem used        : 2.21G (pg-node275)
run_r_script_14706855.log:Max Mem used        : 2.47G (pg-node275)
run_r_script_14706852.log:Max Mem used        : 1.83G (pg-node276)
run_r_script_14706849.log:Max Mem used        : 2.12G (pg-node276)
run_r_script_14706854.log:Max Mem used        : 1.83G (pg-node276)
run_r_script_14706833.log:Max Mem used        : 1.44G (pg-node276)
```

### 4k sequences, 10 GB

 * [http://richelbilderbeek.nl/bbbq_2_4k.zip](http://richelbilderbeek.nl/bbbq_2_4k.zip)

```
run_r_script_14708217.log:Used walltime       : 00:17:45
run_r_script_14708219.log:Used walltime       : 00:08:29
run_r_script_14708228.log:Used walltime       : 00:05:12
run_r_script_14708218.log:Used walltime       : 00:06:03
run_r_script_14708227.log:Used walltime       : 00:09:37
run_r_script_14708223.log:Used walltime       : 00:19:30
run_r_script_14708232.log:Used walltime       : 00:10:59
run_r_script_14708231.log:Used walltime       : 00:06:19
run_r_script_14708229.log:Used walltime       : 00:16:01
run_r_script_14708215.log:Used walltime       : 00:12:21
run_r_script_14708213.log:Used walltime       : 00:51:11
run_r_script_14708211.log:Used walltime       : 00:28:01
run_r_script_14708199.log:Used walltime       : 00:01:36
run_r_script_14708212.log:Used walltime       : 02:07:50
run_r_script_14708222.log:Used walltime       : 00:38:13
run_r_script_14708226.log:Used walltime       : 00:26:19
run_r_script_14708214.log:Used walltime       : 00:26:31
run_r_script_14708220.log:Used walltime       : 00:02:42
run_r_script_14708210.log:Used walltime       : 00:18:15
run_r_script_14708230.log:Used walltime       : 00:05:39
run_r_script_14708221.log:Used walltime       : 00:46:01
run_r_script_14708216.log:Used walltime       : 00:06:11
run_r_script_14708225.log:Used walltime       : 00:21:10
```

```
run_r_script_14708215.log:Max Mem used        : 3.19G (pg-node276)
run_r_script_14708223.log:Max Mem used        : 3.23G (pg-node275)
run_r_script_14708214.log:Max Mem used        : 3.47G (pg-node276)
run_r_script_14708213.log:Max Mem used        : 4.60G (pg-node276)
run_r_script_14708230.log:Max Mem used        : 2.25G (pg-node275)
run_r_script_14708225.log:Max Mem used        : 3.54G (pg-node275)
run_r_script_14708226.log:Max Mem used        : 3.39G (pg-node275)
run_r_script_14708212.log:Max Mem used        : 7.31G (pg-node276)
run_r_script_14708229.log:Max Mem used        : 3.28G (pg-node275)
run_r_script_14708199.log:Max Mem used        : 1.44G (pg-node276)
run_r_script_14708217.log:Max Mem used        : 3.14G (pg-node276)
run_r_script_14708219.log:Max Mem used        : 2.70G (pg-node276)
run_r_script_14708216.log:Max Mem used        : 2.37G (pg-node276)
run_r_script_14708222.log:Max Mem used        : 4.83G (pg-node275)
run_r_script_14708228.log:Max Mem used        : 2.37G (pg-node275)
run_r_script_14708221.log:Max Mem used        : 4.79G (pg-node275)
run_r_script_14708220.log:Max Mem used        : 1.94G (pg-node276)
run_r_script_14708232.log:Max Mem used        : 2.76G (pg-node276)
run_r_script_14708227.log:Max Mem used        : 2.49G (pg-node275)
run_r_script_14708231.log:Max Mem used        : 2.45G (pg-node275)
run_r_script_14708218.log:Max Mem used        : 2.65G (pg-node276)
run_r_script_14708211.log:Max Mem used        : 3.59G (pg-node276)
run_r_script_14708210.log:Max Mem used        : 2.88G (pg-node276)
```

### 8k sequences, 10 GB, FAILED

 * [http://richelbilderbeek.nl/bbbq_2_8k_failed.zip](http://richelbilderbeek.nl/bbbq_2_8k_failed.zip)

```
run_r_script_14716095.log:Used walltime       : 00:46:36
run_r_script_14716100.log:Used walltime       : 00:08:06
run_r_script_14716106.log:Used walltime       : 01:20:06
run_r_script_14716093.log:Used walltime       : 01:49:05
run_r_script_14716108.log:Used walltime       : 00:32:58
run_r_script_14716096.log:Used walltime       : 00:22:59
run_r_script_14716097.log:Used walltime       : 01:08:49
run_r_script_14716087.log:Used walltime       : 01:12:16
run_r_script_14716111.log:Used walltime       : 00:19:00
run_r_script_14716107.log:Used walltime       : 01:39:27
run_r_script_14716077.log:Used walltime       : 00:01:43
run_r_script_14716099.log:Used walltime       : 00:32:44
run_r_script_14716109.log:Used walltime       : 00:17:52
run_r_script_14716105.log:Used walltime       : 01:08:49
run_r_script_14716090.log:Used walltime       : 03:05:35
run_r_script_14716088.log:Used walltime       : 01:35:56
run_r_script_14716102.log:Used walltime       : 01:55:50
run_r_script_14716112.log:Used walltime       : 00:21:40
run_r_script_14716110.log:Used walltime       : 00:59:40
run_r_script_14716089.log:Used walltime       : 05:48:56
run_r_script_14716098.log:Used walltime       : 00:22:28
run_r_script_14716101.log:Used walltime       : 02:29:34
run_r_script_14716113.log:Used walltime       : 00:37:05
```

```
run_r_script_14716100.log:Max Mem used        : 2.67G (pg-node276)
run_r_script_14716106.log:Max Mem used        : 9.09G (pg-node275)
run_r_script_14716093.log:Max Mem used        : 9.30G (pg-node276)
run_r_script_14716108.log:Max Mem used        : 4.68G (pg-node275)
run_r_script_14716096.log:Max Mem used        : 4.37G (pg-node275)
run_r_script_14716097.log:Max Mem used        : 7.51G (pg-node275)
run_r_script_14716087.log:Max Mem used        : 6.55G (pg-node276)
run_r_script_14716111.log:Max Mem used        : 3.92G (pg-node275)
run_r_script_14716107.log:Max Mem used        : 8.35G (pg-node276)
run_r_script_14716099.log:Max Mem used        : 6.00G (pg-node276)
run_r_script_14716109.log:Max Mem used        : 4.46G (pg-node275)
run_r_script_14716105.log:Max Mem used        : 7.79G (pg-node275)
run_r_script_14716090.log:Max Mem used        : 9.94G (pg-node276)
run_r_script_14716088.log:Max Mem used        : 8.54G (pg-node276)
run_r_script_14716102.log:Max Mem used        : 9.87G (pg-node275)
run_r_script_14716112.log:Max Mem used        : 4.85G (pg-node275)
run_r_script_14716110.log:Max Mem used        : 7.86G (pg-node275)
run_r_script_14716089.log:Max Mem used        : 9.85G (pg-node276)
run_r_script_14716098.log:Max Mem used        : 5.35G (pg-node275)
run_r_script_14716101.log:Max Mem used        : 9.99G (pg-node276)
run_r_script_14716113.log:Max Mem used        : 6.15G (pg-node274)
```

8k sequences, 20 GB unknown:


```
?
```
