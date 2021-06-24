<!-- Load common header -->
<?php $this->load->view('common/header'); ?>

<!-- Load common left panel -->
<?php $this->load->view('common/left_panel'); ?>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1><?= $heading; ?>
      </h1>
      <ol class="breadcrumb">
        <li><a href="<?= site_url(DASHBOARD); ?>"><i class="fa fa-dashboard"></i> Dashboard</a></li>
        <li><?= $bread; ?></li>
      </ol>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">

          <div class="box bShow">
            <div class="box-header col-md-12">
              <div class="col-md-4 box-title paddLeft"><?= $heading; ?></div>
              <div class="col-md-4"></div>
              <div class="col-md-4 text-right paddRight">
                <!-- <?php if(!empty($import)) { ?>  
                   <?php  echo  $import; ?>
                <?php } ?> -->
                <a href="<?= site_url(SPINROLLCREATE); ?>" class="btn btn-primary"><?= $create_button; ?></a>
              </div>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <table class="table table-bordered table-striped" id="example_datatable" style="width: 100%;">
                <thead>
                <tr>
                           <th>Sr. No.</th>
                           <th>Title</th>
                           <th>value</th>
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
        </div>
        <!-- /.col -->
      </div>
      <!-- /.row -->
    </section>
    <!-- /.content -->
     <input type="hidden" name="status" id="status" value="<?php echo site_url(GAMEPLAYSTATUS); ?>">
  </div>
  <!-- /.content-wrapper -->

<script type="text/javascript">
  var url = '<?= site_url(SPINROLLAJAX); ?>';
   
  var actioncolumn=4 ;
  var pageLength='';
</script>
<script type="text/javascript">
	 function change_status(id)
	 { 
		 $("#Statusmodal").modal('show');
		 $("#statusSuccBtn").click(function(){
		 var site_url = $("#site_url").val();
		 var url = site_url+"/<?= SPINROLLSTATUS; ?>";
		
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

	 function deleteCountry(id) {
			 $("#Deletemodal").modal('show');
			 $("#deleteSuccBtn").click(function(){
				 var site_url   = $("#site_url").val();
				 var url        =  site_url+"/<?= SPINROLLDELETE; ?>";
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

  <!-- Load common footer -->
<?php $this->load->view('common/footer'); ?>

