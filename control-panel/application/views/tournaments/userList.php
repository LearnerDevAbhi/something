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
        <li><a href="<?= site_url(TOURNAMENTS); ?>"> <?= $head;?></a></li>
        <li><?= $bread; ?></li>
      </ol>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">
          <div class="box bShow">
            <div class="box-header with-border">
              <div class="col-md-4 box-title paddLeft"><?= $heading; ?></div>
               <div class="col-md-4" id="msgHide" ></div>
               <div class="col-md-4 text-right paddRight">
                <input type="hidden" class="filter_search_data" value="<?= $tournamentId;?>">
                <a href="<?= site_url(TOURNAMENTS);?>"><button class="btn btn-danger btn-sm">Back</button></a>
              </div> 
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <!-- <table class="table table-bordered table-striped example_datatable" style="width: 100%;"> -->
              <table class="table table-bordered table-striped" id="example_datatable" style="width: 100%;">
                <thead>
                <tr>
                  <th>Sr. No.</th>
                  <th>User Name</th>
                  <th>Entry Fee</th>
                  <th>Is Enter</th>
                  <!-- <th>Is Win</th> -->
                  <th>Round</th>
                  <th>Is Delete</th>
                  <th>Round Status </th>
                  <th>Date</th>
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

<script type="text/javascript">
  var url = '<?= site_url(TOURNAMENTUSERAJAX); ?>';
    var actioncolumn=8;
    var  pageLength='';
</script>
<script type="text/javascript">

  
function deleteTournaments(tournamentId) {
  $("#Deletemodal").modal('show');
  $("#delId").val(tournamentId);
}

function deleteData(){
  var site_url   = $("#site_url").val();
  var id   = $("#delId").val();
  var url  =  site_url+"/<?= TOURNAMENTSDELETE; ?>";
  
  $.ajax({
    type:'post',
    url:url,
    data:{[csrfName]:csrfHash,id:id},
    success:function(response){
      var obj   = JSON.parse(response);
      csrfName = obj.csrfName;
      csrfHash = obj.csrfHash;
      $("#Deletemodal").modal('hide');
       table.draw();
       $("#msgModal").modal('show');
       $(".changeMsg").html(obj.msg);
       setTimeout(function(){$(".close").click()},3000);
    }
  });
}

function statusChange(tournamentId){
  $("#Statusmodal").modal('show');
  $("#statusId").val(tournamentId);
}
function statusChangeData(){
  var site_url   = $("#site_url").val();
  var id   = $("#statusId").val();
  var url  =  site_url+"/<?= TOURNAMENTSSTATUS; ?>";
  $.ajax({
    type:'post',
    url:url,
    data:{[csrfName]:csrfHash,id:id},
    success:function(response){
      var obj   = JSON.parse(response);
      csrfName = obj.csrfName;
      csrfHash = obj.csrfHash;
      $("#Statusmodal").modal('hide');
      table.draw();
      $("#msgModal").modal('show');
      $(".changeMsg").html(obj.msg);
      setTimeout(function(){$(".close").click()},3000);
    }
  });
}
</script>
  <!-- Load common footer -->
<?php $this->load->view('common/footer.php'); ?>
<script type="text/javascript" src="<?= base_url(); ?>assets/custom_js/spinWheels.js"></script>
