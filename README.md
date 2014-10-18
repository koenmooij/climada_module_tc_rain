climada_module_tc_rain
======================

This climada module implements tropical cyclone torrential rain (TR) hazard event sets

Simply read the header in climada_tr_hazard_set.m, all other code are subroutines

The full climada manual does document the torrential (TR) module, too.

In order to grant core climada access to additional modules, create a folder ‘modules’ in the core climada folder and copy/move any additional modules into climada/modules, without 'climada_module_' in the filename. 

E.g. if the addition module is named climada_module_MODULE_NAME, we should have
.../climada the core climada, with sub-folders as
.../climada/code
.../climada/data
.../climada/docs
and then
.../climada/modules/MODULE_NAME with contents such as 
.../climada/modules/MODULE_NAME/code
.../climada/modules/MODULE_NAME/data
.../climada/modules/MODULE_NAME/docs
this way, climada sources all modules' code upon startup

see climada/docs/climada_manual.pdf to get started

copyright (c) 2014, David N. Bresch, david.bresch@gmail.com all rights reserved.

