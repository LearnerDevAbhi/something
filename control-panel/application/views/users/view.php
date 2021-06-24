<!-- Load common header -->
<?php $this->load->view('common/header'); ?>
<!-- Load common left panel -->
<?php $this->load->view('common/left_panel'); ?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
   <!-- Content Header (Page header) -->
   <section class="content-header">
      <h1><?= $heading; ?></h1><a href="<?= site_url(USERS); ?>" style="float:right;" class="btn btn-danger">Back</a>&nbsp;
   </section>
   <!-- Main content -->
   <section class="content">
      <div class="row">
         <div class="col-md-3">
            <!-- User Profile -->        
            <div class="box" style="border-top:2px solid Blue;">
               <div class="box-body box-profile">
                  <?php if(!empty($getUserData->profile_img)){?>
                  <img class="profile-user-img img-responsive img-circle" src="<?= base_url('uploads/userProfileImages/'.$getUserData->profile_img); ?>" alt="picture"/>
                  <?php }else{ ?>
                  <img class="profile-user-img img-responsive img-circle" src="<?= base_url('uploads/default.png'); ?>" alt="picture"/>
                  <?php } ?>
                  <h3 class="profile-username text-center"><?php if(!empty($getUserData->name)){ echo $getUserData->name;}else{ echo 'NA';}?></h3>

                  <a class="users-list-name text-center" href="javascript:void(0)">Username: <?= !empty($getUserData->user_name) ? $getUserData->user_name : 'NA'; ?> </a>

                  <a class="users-list-name text-center" href="javascript:void(0)">ID: <?= !empty($getUserData->user_id) ? $getUserData->user_id : 'NA'; ?> </a>

                  <a class="users-list-name text-center" href="javascript:void(0)"><?= !empty($getUserData->email_id) ? $getUserData->email_id : 'NA'; ?>
                  <?php if(!empty($getUserData->is_emailVerified=="Yes")) {  ?>
                  <span class="" style="color:green;">&nbsp;<i class="fa fa-check-circle" aria-hidden="true"></i></span>
                  <?php }else { ?>
                  <span class="" style="color:red;">&nbsp;<i class="fa fa-close" aria-hidden="true"></i></span>
                  <?php } ?>
                  </a>
                  <?php if(!empty($getUserData->is_emailVerified=="No")) {  ?>
                  <center><span class="btn btn-success btn-xs" id="emailBtn" onclick="return verifyEmail('<?= $getUserData->id; ?>')">Verify Email </span></center> <?php } ?>
               </div>
               <div class="box-header with-border"></div>
               <div class="box-header with-border">
                  <strong><i class="margin-r-5"></i> Mobile</strong>
                  <?php if(!empty($getUserData->is_mobileVerified=="Yes")) {  ?>
                  <span class="pull-right" style="color:green;">&nbsp;<i class="fa fa-check-circle" aria-hidden="true"></i></span>
                  <?php }else { ?>
                  <span class="pull-right" style="color:red;">&nbsp;<i class="fa fa-close" aria-hidden="true"></i></span>
                  <?php } ?>
                  <span class="text-muted pull-right">
                  <?php if(!empty($getUserData->mobile)){ echo $getUserData->mobile;}else{ echo 'NA';}?>
                  </span>
               </div>
               <div class="box-header with-border">
                  <strong><i class="margin-r-5"></i>Status</strong>
                  <span class="text-muted pull-right">
                  <?php  
                     if(!empty($getUserData->status) && $getUserData->status=='Active' ){ 
                         echo '<a class="btn btn-xs btn-success">'.ucfirst($getUserData->status).'</a>'; 
                     }  elseif($getUserData->status=='Inactive'){ 
                         echo '<a class="btn btn-xs btn-danger">'.ucfirst($getUserData->status).'</a>'; 
                     }else{
                         echo 'NA';
                     }
                     ?>
                  </span>
               </div>
               <!-- <div class="box-header with-border">
                  <strong><i class="margin-r-5"></i> Verification</strong>
                  <span class="text-muted pull-right"> 
                  <?php  
                     if(!empty($getUserData->kyc_status) && $getUserData->kyc_status=='Verified' ){ 
                         echo '<a class="btn btn-xs btn-success">'.ucfirst($getUserData->kyc_status).'</a>'; 
                     }  elseif($getUserData->kyc_status=='Rejected'){ 
                         echo '<a class="btn btn-xs btn-danger">'.ucfirst($getUserData->kyc_status).'</a>'; 
                     }else{
                     echo '<a class="btn btn-xs btn-warning">'.ucfirst($getUserData->kyc_status).'</a>'; 
                     }
                     ?>
                  </span>
                  </div>-->
               <div class="box-header with-border" id="mainWallet">
                  <strong><i class="margin-r-5"></i>Main Wallet</strong>
                  <span class="text-muted">
                  <span class="text-muted pull-right"><?= !empty($getUserData->mainWallet) ? number_format($getUserData->mainWallet,2) : '0'; ?></span>
                  </span>
               </div>
               <div class="box-header with-border" id="winWallet">
                  <strong><i class="margin-r-5"></i> Win Wallet</strong>
                  <span class="text-muted pull-right"><?= !empty($getUserData->winWallet) ? number_format($getUserData->winWallet,2) : '0'; ?></span>
               </div>
               <div class="box-header with-border">
                  <strong><i class="margin-r-5"></i>Referral Users</strong>
                  <!-- <span class="btn btn-xs btn-primary pull-right"><a href="<?= site_url(REFERRALVIEW.'/'.base64_encode($refUsers->fromUserId))?>"><?= !empty($refUserCount) ? $refUserCount : '0'; ?></a></span> -->
                  <?php if(!empty($refUserCount)) { ?>
                    <!--  <a href="<?= site_url(REFERRALVIEW.'/'.base64_encode($getUserData->id))?>" class="btn btn-xs btn-primary pull-right"><?= $refUserCount; ?></a> -->
                     <a href="javascript:void(0)" class="btn btn-xs btn-primary pull-right" style="cursor: default;"><?= $refUserCount; ?></a>
                  <?php } else { ?>
                     <a href="javascript:void(0)" class="btn btn-xs btn-primary pull-right" style="cursor: default;">0</a>
                  <?php }  ?>
               </div>
               <div class="box-header with-border">
                  <strong><i class="margin-r-5"></i>Coupons</strong>
                  <?php if(!empty($refUserCount)) { ?>
                     <a class="btn btn-xs btn-primary pull-right" style="cursor: default;"><?= $couponCount; ?></a>
                  <?php } else { ?>
                     <a class="btn btn-xs btn-primary pull-right" style="cursor: default;">0</a>
                  <?php }  ?>
               </div>
               <div class="box-header with-border" id="refBtn">
                  <!-- <?php  if(!empty($getUserData->status) && $getUserData->status=='Active' ) { ?>
                  <button type="button" class="btn btn-block btn-danger" onclick="return change_status(<?php echo $getUserData->id; ?>)">Deactivate</button>
                  <?php } else { ?>
                  <button type="button" class="btn btn-block btn-success" onclick="return change_status(<?php echo $getUserData->id; ?>)">Activate</button>
                  <?php } ?> -->
                  <button type="button" class="btn btn-block btn-info"  onclick="addMoney('<?= $getUserData->id; ?>')">Add Money</button>
                  <button type="button" class="btn btn-block btn-danger" onclick="deductMoney('<?= $getUserData->id; ?>')" >Deduct Money</button><br>
                  <a href="<?= site_url(USERKYCVIEW.'/'.base64_encode($getUserData->id));?>"><button type="button" class="btn btn-block btn-warning">Kyc Info</button></a>
                  <!-- <button type="button" class="btn btn-block btn-warning" data-toggle="modal" data-target="#" onclick="return ChngPass('<?= $getUserData->id; ?>')">Change Password</button> -->
               </div>
            </div>
            <!-- Device Info Box -->
            <div class="box box-primary">
               <div class="box-header with-border">
                  <h3 class="box-title">Device Info</h3>
               </div>
               <!-- /.box-header -->
               <div class="box-body">
                  <strong><i class="margin-r-5"></i> Device Name</strong>
                  <p class="text-aqua"> <?php if(!empty($getUserData->deviceName)) echo $getUserData->deviceName; else echo "NA"; ?></p>
                  <strong><i class="margin-r-5"></i> Device Model</strong>
                  <p class="text-aqua"> <?php if(!empty($getUserData->deviceModel)) echo $getUserData->deviceModel; else echo "NA"; ?></p>
                  <strong><i class="margin-r-5"></i> OS</strong>
                  <p class="text-aqua" style="word-break: break-all;"> <?php if(!empty($getUserData->deviceOs)) echo $getUserData->deviceOs; else echo "NA"; ?></p>
                  <strong><i class="margin-r-5"></i> RAM (MB)</strong>
                  <p class="text-aqua"> <?php if(!empty($getUserData->deviceRam)) echo $getUserData->deviceRam; else echo "NA"; ?></p>
                  <strong><i class="margin-r-5"></i> Processor</strong>
                  <p class="text-aqua"> <?php if(!empty($getUserData->deviceProcessor)) echo $getUserData->deviceProcessor; else echo "NA"; ?></p>
                  <hr>
               </div>
               <!-- /.box-body -->
            </div>
            <!-- /.box -->
         </div>
         <div class="col-md-9">
            <div class="row">
               <div class="col-md-12" style="padding-left: 3px !important;">
                  <div class="nav-tabs-custom" style="border-top:2px solid gray; margin:0px 0px 15px 0; padding:0 10px 0 10px;">
                     <div class="col-md-2" style="float:right;margin-top:5px;">
                        <a href="<?= site_url(USERGAMEPLAYEDEXPORT.'/'.base64_encode($getUserData->id)); ?>" style="float:right;" class="btn btn-success">Export</a>&nbsp;
                     </div>
                     <div class="" id="gamePlayed">
                        <h4>Game Played</h4>
                        <!-- <a href="javascript:void(0)" class="btn btn-default">Excel</a>&nbsp;
                           <a href="javascript:void(0)"class="btn btn-default">CSV</a>&nbsp;
                           <a href="javascript:void(0)" class="btn btn-default">PDF</a> -->
                        <div class="table-responsive">
                           <table class="table table-bordered table-striped" id="example_datatable" width="100%">
                              <thead>
                                 <tr>
                                    <th>#</th>
                                    <th>Table Id</th>
                                    <!-- <th>Game</th> -->
                                    <th>Game Type</th>
                                    <th>Bet Value</th>
                                    <th>Is Win</th>
                                    <th>Win/Loss Coins</th>
                                    <th>Admin Commission</th>
                                    <th>Admin Amount</th>
                                    <th>Date & Time</th>
                                 </tr>
                              </thead>
                              <tbody>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <div class="row">
               <div class="col-md-12" style="padding-left: 3px !important;">
                  <div class="nav-tabs-custom" style="border-top:2px solid gray; margin:0px 0px 15px 0; padding:0 10px 0 10px;">
                     <!-- <div class="col-md-2" style="float:right;margin-top:5px;">
                        <a href="<?= site_url(USERGAMEPLAYEDEXPORT.'/'.base64_encode($getUserData->id)); ?>" style="float:right;" class="btn btn-success">Export</a>&nbsp;
                     </div> -->
                     <div class="" id="coupon">
                        <h4>Coupon History</h4>
                        <!-- <a href="javascript:void(0)" class="btn btn-default">Excel</a>&nbsp;
                           <a href="javascript:void(0)"class="btn btn-default">CSV</a>&nbsp;
                           <a href="javascript:void(0)" class="btn btn-default">PDF</a> -->
                        <div class="table-responsive">
                           <table class="table table-bordered table-striped" id="coupon_datatable" width="100%">
                              <thead>
                                 <tr>
                                    <th>#</th>
                                    <!-- <th>User Name</th> -->
                                    <th>Coupon Name</th>
                                    <th>Coupon Code</th>
                                    <th>Coupon Amount</th>
                                    <th>Date & Time</th>
                                 </tr>
                              </thead>
                              <tbody>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <div class="row">
               <div class="col-md-6" style="padding-right: 7px !important; padding-left: 3px !important;">
                  <div class="nav-tabs-custom" style="border-top:2px solid red; margin:0px 0px 15px 0; padding:0 10px 0 10px;">
                     <div style="float:right;margin-top:5px;">
                        <a href="<?= site_url(USERCOMPWITHDRAWEXPORT.'/'.base64_encode($getUserData->id)); ?>" style="float:right;" class="btn btn-success">Export</a>&nbsp;
                     </div>
                     <div class="" id="withdraw">
                        <h4>Completed Withdrawal</h4>
                        <!--  <a href="javascript:void(0)" class="btn btn-default">Excel</a>&nbsp;
                           <a href="javascript:void(0)"class="btn btn-default">CSV</a>&nbsp;
                           <a href="javascript:void(0)" class="btn btn-default">PDF</a> -->
                        <div class="table-responsive">
                           <table class="table table-bordered table-striped" id="compWith_datatable" width="100%">
                              <thead>
                                 <tr>
                                    <th>#</th>
                                    <th>Order Id</th>
                                    <th>Amount</th>
                                    <th>Transaction Mode</th>
                                    <th>Status</th>
                                    <th>Date & Time</th>
                                 </tr>
                              </thead>
                              <tbody>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-md-6" style="padding-left: 7px !important;">
                  <div class="nav-tabs-custom" id="example" style="border-top:2px solid skyBlue; margin:0px 0px 15px 0; padding:0 10px 0 10px;">
                     <div style="float:right;margin-top:5px;">
                        <a href="<?= site_url(USERCOMPDEPOSITEXPORT.'/'.base64_encode($getUserData->id)); ?>" style="float:right;" class="btn btn-success">Export</a>&nbsp;
                     </div>
                     <div class="" id="deposite">
                        <h4>Completed Deposit</h4>
                        <!--  <a href="javascript:void(0)" class="btn btn-default">Excel</a>&nbsp;
                           <a href="javascript:void(0)"class="btn btn-default">CSV</a>&nbsp;
                           <a href="javascript:void(0)" class="btn btn-default">PDF</a> -->
                        <div class="table-responsive">
                           <table class="table table-bordered table-striped"  id="compDeposit_datatable" width="100%">
                              <thead>
                                 <tr>
                                    <th>#</th>
                                    <th>Order Id</th>
                                    <th>Amount</th>
                                    <th>Transaction Mode</th>
                                    <th>Type</th>
                                    <th>Status</th>
                                    <th>Date & Time</th>
                                 </tr>
                              </thead>
                              <tbody>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <div class="row">
               <div class="col-md-6" style="padding-right: 7px !important; padding-left: 3px !important;">
                  <div class="nav-tabs-custom" style="border-top:2px solid green; margin:0px 0px 15px 0; padding:0 10px 0 10px;">
                     <div style="float:right;margin-top:5px;">
                        <a href="<?= site_url(USERREFERALBONUSEXPORT.'/'.base64_encode($getUserData->id)); ?>" style="float:right;" class="btn btn-success">Export</a>&nbsp;
                     </div>
                     <div class="" id="withdraw">
                        <h4>Register Referral Bonus</h4>
                        <!--  <a href="javascript:void(0)" class="btn btn-default">Excel</a>&nbsp;
                           <a href="javascript:void(0)"class="btn btn-default">CSV</a>&nbsp;
                           <a href="javascript:void(0)" class="btn btn-default">PDF</a> -->
                        <div class="table-responsive">
                           <table class="table table-bordered table-striped" id="bonus_datatable" width="100%">
                              <thead>
                                 <tr>
                                    <th>#</th>
                                    <th>Referral User</th>
                                    <th>Bonus Amount</th>
                                    <th>Type</th>
                                    <th>Date & Time</th>
                                 </tr>
                              </thead>
                              <tbody>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="col-md-6" style="padding-left: 7px !important;">
                  <div class="nav-tabs-custom" style="border-top:2px solid orange; margin:0px 0px 15px 0; padding:0 10px 0 10px;">
                     <div style="float:right;margin-top:5px;">
                        <a href="<?= site_url(USEGAMEPLAYBONUSEXPORT.'/'.base64_encode($getUserData->id)); ?>" style="float:right;" class="btn btn-success">Export</a>&nbsp;
                     </div>
                     <div class="" id="withdraw">
                        <h4>Game play Bonus</h4>
                        <!--  <a href="javascript:void(0)" class="btn btn-default">Excel</a>&nbsp;
                           <a href="javascript:void(0)"class="btn btn-default">CSV</a>&nbsp;
                           <a href="javascript:void(0)" class="btn btn-default">PDF</a> -->
                        <div class="table-responsive">
                           <table class="table table-bordered table-striped" id="playGame_datatable" width="100%">
                              <thead>
                                 <tr>
                                    <th>#</th>
                                    <th>Referral User</th>
                                    <th>Bonus Amount</th>
                                    <th>Type</th>
                                    <th>Matches</th>
                                    <th>Date & Time</th>
                                 </tr>
                              </thead>
                              <tbody>
                              </tbody>
                           </table>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
      </div>
      <!-- /.row -->
      <!-- Add Money modal -->
      <div class="modal fade" id="addMoney">
         <div class="modal-dialog">
            <div class="modal-content">
               <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span></button>
                  <h4 class="modal-title">Add Money</h4>
               </div>
               <div class="modal-body">
                  <input type="hidden" name="userId" id="userId">
                  <div class="form-group">
                     <label for="amount">Amount<span class="text-danger"> * </span><span id="err_amount" class="text-danger"></span></label>
                     <input type="text" class="form-control" name="amount" id="amount" placeholder="Amount" value="" autocomplete="off" onkeypress="only_number(event)" />
                  </div>
                  <!-- <div class="form-group">
                     <label for="amount">Txn Mode<span class="text-danger"> * </span><span id="err_txnMode" class="text-danger"></span></label>
                     <select class="form-control" name="txnMode" id="txnMode" autocomplete="off">
                        <option value="">Select Mode</option>
                        <option value="bonus">Bonus</option>
                        <option value="refund">Refund</option>
                     </select>
                  </div> -->
                  <div class="form-group">
                     <label for="amount">Add to<span class="text-danger"> * </span>
                     <span id="addTo_err" class="text-danger"></span></label><br>
                     <input type="radio"  name="addTo" id="addTo"  value="mainWallet" autocomplete="off" checked="true" /> Main Wallet &nbsp;&nbsp;
                     <input type="radio"  name="addTo" id="addTo" value="winWallet" autocomplete="off"/>Win Wallet &nbsp;&nbsp;
                     <!-- <input type="radio"  name="addTo" id="addTo" value="bonus" autocomplete="off"/> Bonus &nbsp;&nbsp;
                     <input type="radio"  name="addTo" id="addTo" value="refund" autocomplete="off"/> Refund -->
                  </div>
                  <div class="form-group">
                     <label for="amount">Transaction Mode<span class="text-danger"> * </span>
                     <span id="addTo_err" class="text-danger"></span></label><br>
                     <select  class="form-control col-md-6" name="transaction_mode" id="transaction_mode">
                        <option value="Bonus">Bonus</option>
                        <option value="Refund">Refund</option>
                     </select>
                  </div>
                  <br>
                  <br>
                  <div class="form-group">
                     <button type="button" id="btnAddmoney" class="btn btn-success" onclick="saveAddMoney()">Submit</button>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default pull-right" data-dismiss="modal">Close</button>
               </div>
            </div>
            <!-- /.modal-content -->
         </div>
         <!-- /.modal-dialog -->
      </div>
      <!-- /.Add Money modal -->
      <!--Deduct Money modal -->
      <div class="modal fade" id="deductMoney">
         <div class="modal-dialog">
            <div class="modal-content">
               <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                  <span aria-hidden="true">&times;</span></button>
                  <h4 class="modal-title">Deduct Money</h4>
               </div>
               <div class="modal-body">
                  <input type="hidden" name="userId" id="userId">
                  <div class="form-group">
                     <label for="amount">Amount<span class="text-danger"> * </span>
                     <span id="deduct_amounterr" class="text-danger"></span></label>
                     <input type="text" class="form-control" name="deduct_amount" id="deduct_amount" placeholder="Amount" value="" autocomplete="off"/>
                  </div>
                  <div class="form-group">
                     <label for="amount">Deduct From <span class="text-danger"> * </span>
                     <span id="deductFrom_err" class="text-danger"></span></label><br>
                     <input type="radio"  name="deductFrom" id="deductFrom"  value="mainWallet" autocomplete="off" checked="true"/> Main Wallet &nbsp;&nbsp;
                     <input type="radio"  name="deductFrom" id="deductFrom" value="winWallet" autocomplete="off"/>Win Wallet
                  </div>
                  <div class="form-group">
                     <button type="button" id="btnDeductmoney" class="btn btn-danger" onclick="saveDeductMoney()">Submit</button>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default pull-right" data-dismiss="modal">Close</button>
               </div>
            </div>
            <!-- /.modal-content -->
         </div>
         <!-- /.modal-dialog -->
      </div>
      <!-- /.Deduct Moneymodal -->

      <!--  Verify Email Modal START -->
      <div class="modal fade" id="emailVerifyModal" tabindex="-1" role="dialog" aria-labelledby="emailVerifyModal" aria-hidden="true">
         <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
               <div class="modal-header bg-info">
                  <div class="col-md-6 paddLeft">
                     <h5 id="smallmodal1" class="modal-title">Verify Email</h5>
                  </div>
                  <div class="col-md-6 paddRight">
                     <button aria-label="Close" data-dismiss="modal" class="close" type="button">
                     <span aria-hidden="true">×</span>
                     </button>
                  </div>
               </div>
               <div class="modal-body">
                  <p id="appendData">Do you really want to verify this email ?</p>
                  <!-- <input type="hidden" name="statusId" id="statusId" value=""/> -->
               </div>
               <div class="modal-footer">
                  <button type="submit" class="btn btn-primary" id="emailVerifyBtn">Yes</button>
                  <button type="button" class="btn btn-secondary" data-dismiss="modal" id="noStatusBtn" onclick="return noStatus();">No</button>
               </div>
            </div>
         </div>
      </div>
      <!-- Verify Email  Modal END -->

      <!--  STATUS CHANGE Modal START -->
      <div class="modal fade" id="chngPassModal" tabindex="-1" role="dialog" aria-labelledby="chngPassModal" aria-hidden="true">
         <div class="modal-dialog modal-sm" role="document">
            <div class="modal-content">
               <div class="modal-header bg-info">
                  <div class="col-md-6 paddLeft">
                     <h5 id="smallmodal1" class="modal-title">Change Password</h5>
                  </div>
                  <div class="col-md-6 paddRight">
                     <button aria-label="Close" data-dismiss="modal" class="close" type="button">
                     <span aria-hidden="true">×</span>
                     </button>
                  </div>
               </div>
               <div class="modal-body">
                  <p id="appendData">Do you really want to change the Password ?</p>
                  <!-- <input type="hidden" name="statusId" id="statusId" value=""/> -->
               </div>
               <div class="modal-footer">
                  <button type="submit" class="btn btn-primary" id="chngPassSuccBtn">Yes</button>
                  <button type="button" class="btn btn-secondary" data-dismiss="modal" id="noStatusBtn" onclick="return noStatus();">No</button>
               </div>
            </div>
         </div>
      </div>
      <!-- STATUS CHANGE  Modal END -->
      <input type="hidden" id="site_url" value="<?php echo site_url(); ?>">
      <input type="hidden" id="url" value="<?php echo site_url('Users/addMoney'); ?>">
      <input type="hidden" id="deductAmtUrl" value="<?php echo site_url('Users/deductMoney'); ?>">
   </section>
   <!-- /.content -->
</div>
<!-- /.content-wrapper -->
<script type="text/javascript">
   var url = '<?= site_url("Users/ajaxGamePlayed/".base64_encode($getUserData->id)); ?>';
   var actioncolumn=8;
   var pageLength='';
</script>
<!-- Load common footer -->
<?php $this->load->view('common/footer'); ?>
<script type="text/javascript">
   // var setNextDataTable = true;
   var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>'
   var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
      setTimeout(function(){
         var table = $('#coupon_datatable').DataTable({
            "oLanguage": { 
               "sProcessing": "<img src='<?= base_url()?>assets/images/loader.gif'>" 
            },
      
            //"scrollX":false,
            "scrollX":true,
            "processing": false, //Feature control the processing indicator.
            "serverSide": true, //Feature control DataTables' server-side processing mode.
            "stateSave": true,
             "order": [], //Initial no order.
             "lengthMenu" : [[10,25, 100,200,500,1000,2000], [10,25, 100,200,500,1000,2000 ]],"pageLength" : 10,
             
             "ajax": {
                 "url":'<?php echo site_url("Users/ajaxCoupon/".base64_encode($getUserData->id)); ?>',
                 "type": "POST",
                
                  "data": function(d) {
                        d.Foo = 'gmm';
                        d.SearchData = $(".filter_search_data").val();
                        d.SearchData1 = $(".filter_search_data1").val();
                        d.SearchData2 = $(".filter_search_data2").val();
                        d.SearchData3 = $(".filter_search_data3").val();
                        d.SearchData4 = $(".filter_search_data4").val();
                        d.SearchData5 = $(".filter_search_data5").val();
                        d[csrfName] = csrfHash;
                        d.FormData = $(".filter_data_form").serializeArray();
                     },
                      "error": function(){
                       console.log("hiii");
                      $.ajax({
                      url: $("#site_url").val()+"/Csrfdata",
                      type: "GET",
                      success: function(response) {
                        $("#csrf_token").val(response);
                          }
                        });
                      }
                },
              "fnDrawCallback": function( ) {
                  var api = this.api();
                  var json = api.ajax.json();
                  csrfName =json.csrfName;
                  csrfHash =json.csrfHash;
                },
             
             "columnDefs": [
             { 
                 "targets": [ 0,4], //first column / numbering column
                 "orderable": false, //set not orderable
             },
             ], 
         });         
      },150)
   
       $(".filter_search_data").change(function(){
         table.draw();
       });
   
       $(".filter_search_data1").change(function(){
         table.draw();
       });
   
       $(".resetBtn").click(function(){
         setTimeout(function(){
           table.draw();
         },20)
       });
</script>
<script type="text/javascript">
   // var setNextDataTable = true;
   var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>'
   var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
      setTimeout(function(){
         var table = $('#compWith_datatable').DataTable({
            "oLanguage": { 
               "sProcessing": "<img src='<?= base_url()?>assets/images/loader.gif'>" 
            },
      
            //"scrollX":false,
            "scrollX":true,
            "processing": false, //Feature control the processing indicator.
            "serverSide": true, //Feature control DataTables' server-side processing mode.
            "stateSave": true,
             "order": [], //Initial no order.
             "lengthMenu" : [[10,25, 100,200,500,1000,2000], [10,25, 100,200,500,1000,2000 ]],"pageLength" : 10,
             
             "ajax": {
                 "url":'<?php echo site_url("Users/ajaxCompWithDrawal/".base64_encode($getUserData->id)); ?>',
                 "type": "POST",
                
                  "data": function(d) {
                        d.Foo = 'gmm';
                        d.SearchData = $(".filter_search_data").val();
                        d.SearchData1 = $(".filter_search_data1").val();
                        d.SearchData2 = $(".filter_search_data2").val();
                        d.SearchData3 = $(".filter_search_data3").val();
                        d.SearchData4 = $(".filter_search_data4").val();
                        d.SearchData5 = $(".filter_search_data5").val();
                        d[csrfName] = csrfHash;
                        d.FormData = $(".filter_data_form").serializeArray();
                     },
                      "error": function(){
                       console.log("hiii");
                      $.ajax({
                      url: $("#site_url").val()+"/Csrfdata",
                      type: "GET",
                      success: function(response) {
                        $("#csrf_token").val(response);
                          }
                        });
                      }
                },
              "fnDrawCallback": function( ) {
                  var api = this.api();
                  var json = api.ajax.json();
                  csrfName =json.csrfName;
                  csrfHash =json.csrfHash;
                },
             
             "columnDefs": [
             { 
                 "targets": [ 0,5], //first column / numbering column
                 "orderable": false, //set not orderable
             },
             ], 
         });         
      },150)
   
       $(".filter_search_data").change(function(){
         table.draw();
       });
   
       $(".filter_search_data1").change(function(){
         table.draw();
       });
   
       $(".resetBtn").click(function(){
         setTimeout(function(){
           table.draw();
         },20)
       });
</script>
<script type="text/javascript">
   var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>'
   var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
      setTimeout(function(){
         var table = $('#compDeposit_datatable').DataTable({
            "oLanguage": { 
               "sProcessing": "<img src='<?= base_url()?>assets/images/loader.gif'>" 
            },
      
            //"scrollX":false,
            "scrollX":true,
            "processing": false, //Feature control the processing indicator.
            "serverSide": true, //Feature control DataTables' server-side processing mode.
            "stateSave": true,
             "order": [], //Initial no order.
             "lengthMenu" : [[10,25, 100,200,500,1000,2000], [10,25, 100,200,500,1000,2000 ]],"pageLength" : 10,
             
             "ajax": {
                 "url":'<?php echo site_url("Users/ajaxCompDeposit/".base64_encode($getUserData->id)); ?>',
                 "type": "POST",
                
                  "data": function(d) {
                        d.Foo = 'gmm';
                        d.SearchData = $(".filter_search_data").val();
                        d.SearchData1 = $(".filter_search_data1").val();
                        d.SearchData2 = $(".filter_search_data2").val();
                        d.SearchData3 = $(".filter_search_data3").val();
                        d.SearchData4 = $(".filter_search_data4").val();
                        d.SearchData5 = $(".filter_search_data5").val();
                        d[csrfName] = csrfHash;
                        d.FormData = $(".filter_data_form").serializeArray();
                     },
                      "error": function(){
                       console.log("hiii");
                      $.ajax({
                      url: $("#site_url").val()+"/Csrfdata",
                      type: "GET",
                      success: function(response) {
                        $("#csrf_token").val(response);
                          }
                        });
                      }
                },
              "fnDrawCallback": function( ) {
                  var api = this.api();
                  var json = api.ajax.json();
                  csrfName =json.csrfName;
                  csrfHash =json.csrfHash;
                },
             
             "columnDefs": [
             { 
                 "targets": [ 0,6 ], //first column / numbering column
                 "orderable": false, //set not orderable
             },
             ],
           
         });
      },300);
   
       $(".filter_search_data").change(function(){
         table.draw();
       });
   
       $(".filter_search_data1").change(function(){
         table.draw();
       });
   
       $(".resetBtn").click(function(){
         setTimeout(function(){
           table.draw();
         },20)
       });
</script>
<script type="text/javascript">
   var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>'
   var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
      setTimeout(function(){
         var table = $('#bonus_datatable').DataTable({
            "oLanguage": { 
               "sProcessing": "<img src='<?= base_url()?>assets/images/loader.gif'>" 
            },
      
            //"scrollX":false,
            "scrollX":true,
            "processing": false, //Feature control the processing indicator.
            "serverSide": true, //Feature control DataTables' server-side processing mode.
            "stateSave": true,
             "order": [], //Initial no order.
             "lengthMenu" : [[10,25, 100,200,500,1000,2000], [10,25, 100,200,500,1000,2000 ]],"pageLength" : 10,
             
             "ajax": {
                 "url":'<?php echo site_url("Users/ajaxBonusList/".base64_encode($getUserData->id)); ?>',
                 "type": "POST",
                
                  "data": function(d) {
                        d.Foo = 'gmm';
                        d.SearchData = $(".filter_search_data").val();
                        d.SearchData1 = $(".filter_search_data1").val();
                        d.SearchData2 = $(".filter_search_data2").val();
                        d.SearchData3 = $(".filter_search_data3").val();
                        d.SearchData4 = $(".filter_search_data4").val();
                        d.SearchData5 = $(".filter_search_data5").val();
                        d[csrfName] = csrfHash;
                        d.FormData = $(".filter_data_form").serializeArray();
                     },
                      "error": function(){
                       console.log("hiii");
                      $.ajax({
                      url: $("#site_url").val()+"/Csrfdata",
                      type: "GET",
                      success: function(response) {
                        $("#csrf_token").val(response);
                          }
                        });
                      }
                },
              "fnDrawCallback": function( ) {
                  var api = this.api();
                  var json = api.ajax.json();
                  csrfName =json.csrfName;
                  csrfHash =json.csrfHash;
                },
             
             "columnDefs": [
             { 
                 "targets": [ 0,4 ], //first column / numbering column
                 "orderable": false, //set not orderable
             },
             ],
           
         });
      },500);
   
       $(".filter_search_data").change(function(){
         table.draw();
       });
   
       $(".filter_search_data1").change(function(){
         table.draw();
       });
   
       $(".resetBtn").click(function(){
         setTimeout(function(){
           table.draw();
         },20)
       });
</script>
<script type="text/javascript">
   var csrfName = '<?php echo $this->security->get_csrf_token_name(); ?>'
   var csrfHash = '<?php echo $this->security->get_csrf_hash(); ?>';
      setTimeout(function(){
         var table = $('#playGame_datatable').DataTable({
            "oLanguage": { 
               "sProcessing": "<img src='<?= base_url()?>assets/images/loader.gif'>" 
            },
      
            //"scrollX":false,
            "scrollX":true,
            "processing": false, //Feature control the processing indicator.
            "serverSide": true, //Feature control DataTables' server-side processing mode.
            "stateSave": true,
             "order": [], //Initial no order.
             "lengthMenu" : [[10,25, 100,200,500,1000,2000], [10,25, 100,200,500,1000,2000 ]],"pageLength" : 10,
             
             "ajax": {
                 "url":'<?php echo site_url("Users/ajaxPlayGameBonusList/".base64_encode($getUserData->id)); ?>',
                 "type": "POST",
                
                  "data": function(d) {
                        d.Foo = 'gmm';
                        d.SearchData = $(".filter_search_data").val();
                        d.SearchData1 = $(".filter_search_data1").val();
                        d.SearchData2 = $(".filter_search_data2").val();
                        d.SearchData3 = $(".filter_search_data3").val();
                        d.SearchData4 = $(".filter_search_data4").val();
                        d.SearchData5 = $(".filter_search_data5").val();
                        d[csrfName] = csrfHash;
                        d.FormData = $(".filter_data_form").serializeArray();
                     },
                      "error": function(){
                       console.log("hiii");
                      $.ajax({
                      url: $("#site_url").val()+"/Csrfdata",
                      type: "GET",
                      success: function(response) {
                        $("#csrf_token").val(response);
                          }
                        });
                      }
                },
              "fnDrawCallback": function( ) {
                  var api = this.api();
                  var json = api.ajax.json();
                  csrfName =json.csrfName;
                  csrfHash =json.csrfHash;
                },
             
             "columnDefs": [
             { 
                 "targets": [ 0,4 ], //first column / numbering column
                 "orderable": false, //set not orderable
             },
             ],
           
         });
      },700);
   
       $(".filter_search_data").change(function(){
         table.draw();
       });
   
       $(".filter_search_data1").change(function(){
         table.draw();
       });
   
       $(".resetBtn").click(function(){
         setTimeout(function(){
           table.draw();
         },20)
       });
</script>
<script type="text/javascript">
   function change_status(id) { 
     $("#Statusmodal").modal('show');
      $("#statusSuccBtn").click(function(){
        var site_url = $("#site_url").val();
        var url = site_url+"/Users/change_status";
         var datastring = "id="+id;
         $.post(url,datastring,function(data){
         var obj = JSON.parse(data);
         csrfName = obj.csrfName;
         csrfHash = obj.csrfHash;
         $("#Statusmodal").modal('hide');
         $("#Statusmodal").load(location.href+" #Statusmodal>*","");
         $("#refBtn").load(location.href+" #refBtn>*","");
         $("#msgData").val(obj.msg);
         $("#toast-fade").click();
       });
     });
   }
   
   function ChngPass(userId){
      $("#chngPassModal").modal('show');
       $("#chngPassSuccBtn").click(function(){
       var site_url = $("#site_url").val();
       var url = site_url+"/Users/change_password";
         var datastring = "userId="+userId;
         $.post(url,datastring,function(data){
           var obj = JSON.parse(data);
           csrfName = obj.csrfName;
           csrfHash = obj.csrfHash;
           $("#chngPassModal").modal('hide');
           $("#msgData").val(obj.msg);
           $("#toast-fade").click();
         });
       });
   }
   
   function verifyEmail(userId){
      $("#emailVerifyModal").modal('show');
       $("#emailVerifyBtn").click(function(){
       var site_url = $("#site_url").val();
       var url = site_url+"/Users/emailVerification";
         var datastring = "userId="+userId;
         $.post(url,datastring,function(data){
           //alert(data);return false;
           var obj = JSON.parse(data);
           csrfName = obj.csrfName;
           csrfHash = obj.csrfHash;
           $("#emailVerifyModal").modal('hide');
           //$("#emailBtn").hide();
           $(".box-profile").load(location.href+" .box-profile>*","");
           $("#msgData").val(obj.msg);
           $("#toast-fade").click();
         });
       });
   }

   function only_number(event){ 
      var x = event.which || event.keyCode;
      if((x >= 48 ) && (x <= 57 ) || x == 46 || x == 8 || x == 9 || x == 13 ){
         return;
      }else{
          event.preventDefault();
      }
   }
   
   
   function addMoney(id){
      var userId = $("#userId").val(id);
      $("#addMoney").modal('show');
   }
   
   function saveAddMoney(){
      var userId = $("#userId").val();
      var amount = $("#amount").val();
      var transaction_mode = $("#transaction_mode").val();
      //  var txnMode = $("#txnMode").val();
      var addTo = $("input[name='addTo']:checked").val();
      //alert(addTo);return false;
      var url = $("#url").val();
      if(amount == ''){
         $("#err_amount").fadeIn().html("Please enter amount.");
         setTimeout(function(){$("#err_amount").html("&nbsp;");},3000);
         $("#amount").focus();
         return false;
      }else if(amount <= 0){
         $("#err_amount").fadeIn().html("Amount should be more than zero");
         setTimeout(function(){$("#err_amount").html("&nbsp;");},5000)
         $("#amount").focus();
         return false;
      }else{
          $("#btnAddmoney").attr('disabled', true);
         var url = url;
         $.ajax({
               type:"post",
               url:url,
               data:{[csrfName]:csrfHash,amount:amount,userId:userId,addTo:addTo,transaction_mode:transaction_mode},
               success:function(result){
                  var obj = JSON.parse(result);
                  csrfName = obj.csrfName;
                  csrfHash = obj.csrfHash;
                  $("#btnAddmoney").attr('disabled', false);
                  $("#addMoney").modal('hide');
                  $("#mainWallet").load(location.href+" #mainWallet>*","");
                  $("#winWallet").load(location.href+" #winWallet>*","");
                  $("#msgData").val(obj.msg);
                  $("#toast-fade").click();
                  $("#amount").val("");
               }
            });
      }
   }
   
   function deductMoney(id){
      var userId = $("#userId").val(id);
      $("#deductMoney").modal('show');
   }
   
   
   function saveDeductMoney(){
      var userId = $("#userId").val();
      var deductAmt = $("#deduct_amount").val();
      var deductAmtUrl = $("#deductAmtUrl").val();
      var addTo = $("input[name='deductFrom']:checked").val();
   
      if(deductAmt == '')
      {
         $("#deduct_amounterr").fadeIn().html("Please enter amount.");
         setTimeout(function(){$("#deduct_amounterr").html("&nbsp;");},3000);
         $("#deduct_amount").focus();
         return false;
      }else if(deductAmt <= 0){
         $("#deduct_amounterr").fadeIn().html("Amount should be more than zero");
         setTimeout(function(){$("#deduct_amounterr").html("&nbsp;");},5000)
         $("#deduct_amount").focus();
         return false;
      }else{
         $("#btnDeductmoney").attr('disabled', true);
         var url = deductAmtUrl;
         $.ajax({
               type:"post",
               url:url,
               data:{[csrfName]:csrfHash,deductAmt:deductAmt,userId:userId,addTo:addTo},
               success:function(result){
                  var obj = JSON.parse(result);
                  csrfName = obj.csrfName;
                  csrfHash = obj.csrfHash;
                  if(obj.success==1){
                     $("#msgData").val(obj.msg);
                  }else{
                      $("#msgData").val(obj.msg);
                  }
                  $("#btnDeductmoney").attr('disabled', false);
                  $("#deductMoney").modal('hide');
                  $("#deductMoney").load(location.href+" #deductMoney>*","");
                  $("#mainWallet").load(location.href+" #mainWallet>*","");
                  $("#winWallet").load(location.href+" #winWallet>*","");
                  $("#toast-fade").click();
                  $("#deduct_amount").val("");
               }
            });
      }
   }
   
   function kycInfo(id){

   }
   
   
</script>