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
              <div class="col-md-4 box-title paddLeft"><?= $heading; ?></div>
              <div class="col-md-4"></div>
              <div class="col-md-4 text-right paddRight">
                <!-- <?php if(!empty($import)) { ?>  
                   <?php  echo  $import; ?>
                 <?php } ?> -->
                <a href="<?= site_url(CUSTOMDICECREATE); ?>" class="btn btn-primary"><?php if(!empty($create_btn)) {  echo  $create_btn; } ?> </a>
              </div>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
                <table class="table table-bordered table-striped" id="example_datatable" style="width: 100%;">
                  <thead>
                  <tr>
                    <th>Sr. No.</th>
                  <th>Name</th>
                  <th>Price</th>
                  <th>counter</th>
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
<script type="text/javascript">
  var url = '<?= site_url(CUSTOMDICEAJAX); ?>';
  var actioncolumn=5;
  var pageLength='';
</script>

  <!-- Load common footer -->
<?php $this->load->view('common/footer.php'); ?>
<script type="text/javascript" src="<?= base_url(); ?>/assets/custom_js/custom_dice.js"></script>
