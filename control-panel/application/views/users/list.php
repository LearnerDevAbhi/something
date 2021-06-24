<!-- Load common header -->
<?php $this->load->view('common/header'); ?>
<!-- Load common left panel -->
<?php $this->load->view('common/left_panel'); ?>
<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
<!-- Content Header (Page header) -->
<section class="content-header">
	 <h1><?= $heading; ?></h1>
</section>
<!-- Main content -->
<section class="content">
	 <div class="row">
			<div class="col-xs-12">
				
					 <div class="box bShow">
						 <div class="box-header">
							 <input type="hidden" class="filter_search_data">
							 &nbsp;
							 <button type="button" id="activeAll" class="btn btn-primary col-xs-1 inactiveClass" onclick="getStatus('All');">All</button>
							 &nbsp;
							 <button type="button" id="activecustom" class="btn btn-default col-xs-1 inactiveClass" onclick="getStatus('custom');">Custom</button>
							 &nbsp;
							 <button type="button" id="activefacebook" class="btn btn-default col-xs-1 inactiveClass" onclick="getStatus('facebook');">Facebook</button>
							 &nbsp;
						 </div>
					 </div>

					 <!--  <div class="col-md-12" style="padding:10px;">
							 <a href="<?= site_url(USEREXPORT); ?>" class="btn btn-default">Excel Export</a>&nbsp;
							 <form>
									<div class="col-md-10">
										 <div class="col-md-4 pull-right paddRight">
												<input type="text" class="form-control datepicker filter_search_data1" name="toDate" id="toDate" placeholder="Select To Date" autocomplete="off">
										 </div>
										 <div class="col-md-4 pull-right paddRight">
												<input type="text" class="form-control datepicker filter_search_data" name="fromDate" id="fromDate" placeholder="Select From Date" autocomplete="off">
										 </div>
									</div>
									<div class="col-md-1">
										 <button type="reset" class="btn btn-warning resetBtn" name="reset" id="reset">Reset</button>
									</div>
							 </form>
						</div> -->
						<!-- /.box-header -->
						<div class="box bShow">
							 <div class="box-header col-md-12">
									<form>
										<!-- <div class="col-md-2 box-title paddLeft"><?= $heading; ?></div> -->

										<div class="col-md-3" id="msgHide"><?php echo $this->session->userdata('message') <> '' ? $this->session->userdata('message') : ''; ?></div>
										<div class="col-md-7">
											 <div class="col-md-4 pull-right paddRight">
													<input type="text" class="form-control datepicker filter_search_data2" name="toDate" id="toDate" placeholder="Select To Date" autocomplete="off">
											 </div>
											 <div class="col-md-4 pull-right paddRight">
													<input type="text" class="form-control datepicker filter_search_data3" name="fromDate" id="fromDate" placeholder="Select From Date" autocomplete="off">
											 </div>
										</div>
										<div class="col-md-1">
											 <button type="reset" class="btn btn-warning resetBtn" name="reset" id="reset">Reset</button>
										</div>
										<div class="col-md-1 box-title paddLeft"> <a href="<?= site_url(USEREXPORT); ?>" class="btn btn-success">Export</a>&nbsp;</div>
									</form>
									<!--   <div class="col-md-4 text-right paddRight"> -->
									<!--   </div> -->
							 </div>
							 <!-- /.box-header -->
							 <div class="box-body">
								<input type="hidden" name="flag" id="flag" value="<?= $flag; ?>">
									<table class="table table-bordered table-striped display" id="example_datatable" style="width: 100%;">
										 <thead>
												<tr>
													 <th>#</th>
													 <th>Username</th>
													 <th>Mobile</th>
													 <th>Game Played</th>
													 <th>Main Wallet</th>
													 <th>Win Wallet</th>
													 <th>Referral Code</th>
													 <th>Reg Date</th>
													 <th>Last Login</th>
													 <th>Block Users</th>
													 <th>kyc Status</th>
													 <th>Status</th>
													 <th>Action</th>
												</tr>
										 </thead>
										 <tbody>
										 </tbody>
									</table>
							 </div>
							 <!-- /.box-body -->
						</div>
						<!-- /.box -->
				 
				 <!-- /.col -->
			</div>
			<!-- /.row -->
</section>
<!-- /.content -->
</div>
<!-- /.content-wrapper -->
<script type="text/javascript">
	 var url = '<?= site_url("Users/ajax_manage_page/"); ?>';
	 var actioncolumn=12;
	 var pageLength='';
</script>
<!-- Load common footer -->
<?php $this->load->view('common/footer'); ?>
<script type="text/javascript">
	$(function() {
		var flag =$("#flag").val();
		if(flag != ''){
			setTimeout(function(){
				getStatus(flag);				
			},70)
		}
	});


	function getStatus(status)
	{
		$('.filter_search_data').val(status);
		$('.inactiveClass').removeClass("btn-default btn-primary");
		$('.inactiveClass').addClass("btn-default");
		$('#active'+status).removeClass("btn-default").addClass("btn-primary");
		table.draw();
	}    


	 function blockuserChange(id)
	 { 
		 $("#Statusmodal").modal('show');
		 $("#statusSuccBtn").click(function(){
		 var site_url = $("#site_url").val();
		 var url = site_url+"/Users/blockUserChange";
			 var datastring = "id="+id+"&"+csrfName+"="+csrfHash;
			 $.post(url,datastring,function(data){
				 $("#Statusmodal").modal('hide');
				 $("#Statusmodal").load(location.href+" #Statusmodal>*","");
				 var obj = JSON.parse(data);
				 csrfName = obj.csrfName;
				 csrfHash = obj.csrfHash;
				 table.draw();
				 $("#msgData").val(obj.msg);
				 $("#toast-fade").click();
			 });
		 });
	 }
</script>
<script type="text/javascript">
	 function change_status(id)
	 { 
		 $("#Statusmodal").modal('show');
		 $("#statusSuccBtn").click(function(){
		 var site_url = $("#site_url").val();
		 var url = site_url+"/Users/change_status";
			 var datastring = "id="+id+"&"+csrfName+"="+csrfHash;
			 $.post(url,datastring,function(data){
				 $("#Statusmodal").modal('hide');
				 $("#Statusmodal").load(location.href+" #Statusmodal>*","");
				 var obj = JSON.parse(data);
				 csrfName = obj.csrfName;
				 csrfHash = obj.csrfHash;
				 table.draw();
				 $("#msgData").val(obj.msg);
				 $("#toast-fade").click();
			 });
		 });
	 }
</script>
<script type="text/javascript">  
	 function User_Validation()
	 { 
		 var import_user = $("#import_user").val(); 
		 if(import_user == "")
		 {  
			 $("#errorUser").html("<span style='color:red;'>Please upload excel</span>").fadeIn();
			 setTimeout(function(){$("#errorUser").fadeOut()},3000);
			 return false; 
		 }
	 }
	 
	 
	 function deleteUser(id) {
			 $("#Deletemodal").modal('show');
			 $("#deleteSuccBtn").click(function(){
				 var site_url   = $("#site_url").val();
				 var url        =  site_url+"/<?= DELUSER; ?>";
				 var datastring =  'id='+id+"&"+csrfName+"="+csrfHash;
				 $.post(url,datastring,function(response){
					 $("#Deletemodal").modal('hide');
					 $("#Deletemodal").load(location.href+" #Deletemodal>*","");
						 var obj   = JSON.parse(response);
						 csrfName = obj.csrfName;
						 csrfHash = obj.csrfHash;
						 table.draw();
						 $("#msgData").val(obj.msg);
						 $("#toast-fade").click();
					 });
			 });
		 }
</script>