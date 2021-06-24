<!-- Load common header -->
<?php $this->load->view('common/header'); ?>

<!-- Load common left panel -->
<?php $this->load->view('common/left_panel.php'); ?>

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
              <form>
                <div class="col-md-2 box-title paddLeft"><?= $heading; ?></div>
              
                <div class="col-md-10 text-right paddRight">
                  <a href="<?= site_url(BOTPLAYERCREATE); ?>" class="btn btn-primary">Create</a>
                  <?php if(!empty($import)) { ?>  
                   <?php  echo  $import; ?>
                  <?php } ?>
                  <!-- <a href="<?= site_url('BotPlayer/Export'); ?>" class="btn btn-info">Export</a> -->
                </div>
                  
              </form>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <table class="table table-bordered table-striped" id="example_datatable" style="width: 100%;">
                <thead>
                <tr>
                  <th>Sr. No.</th>
                  <th>User Name</th>
                  <th>Country Name</th>
                  <!-- <th>Balance</th> -->
                  <th>Profile Image</th>
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
  </div>
  <!-- /.content-wrapper -->
<!-- Excel upload modal  --> 
<div class="modal fade" id="uploadData" data-modal-color="lightblue" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">   
            <form method="post" action="<?= $importAction;?>" method="post" enctype="multipart/form-data"> 
                <div class="modal-header">
                   <span style="font-size:20px" id="error_msg" ><?= $importTitle;?></span>
                </div>     
                <div class="modal-body" style="padding-top: 3%">
                    <input type="file" name="excel_file" id="excel_file" class="form-control">
                        &nbsp;<span style="color:red" id="err_excel_file"></span>&nbsp;
                </div>
                <div class="modal-footer">
                    <a href="<?= $importSheet;?>" class="btn btn-primary">Download Excel</a>
                    <button type="submit" class="btn btn-success" onclick="return validations()">Save</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
<script type="text/javascript">
  var url = '<?= site_url(BOTPLAYERAJAX); ?>';
  var actioncolumn=5;
  var pageLength='';
</script>
<!-- Load common footer -->
<?php $this->load->view('common/footer.php'); ?>
<script type="text/javascript" src="<?php echo base_url(); ?>assets/custom_js/import.js"></script>
<script type="text/javascript">
  function deletebotplayer(id){
    $("#Deletemodal").modal('show');
    $("#deleteSuccBtn").click(function(){
      var site_url   = $("#site_url").val();
      var url        =  site_url+"/<?= BOTPLAYERDELETE; ?>";
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