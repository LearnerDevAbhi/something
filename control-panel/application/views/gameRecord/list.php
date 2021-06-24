<!-- Load common header -->
<?php $this->load->view('common/header'); ?>
<link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" />
<!-- Load common left panel -->
<?php $this->load->view('common/left_panel.php'); ?>

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
            <div class="box-header col-md-12">
				<div align="center" class="box-header col-md-12">
					<select name="users" > 
              <option value="0">Search Users</option>
              <?php if(!empty($getUsers)) { foreach ($getUsers as $users) { ?>
              <option value="<?= $users->id; ?>"><?= $users->user_name; ?></option>
            <?php } } ?>
          </select>
					 <button type="button" class="btn btn-primary pull-right" name="" id="reset">EXPORT</button>
				</div>
            </div>
            <!-- /.box-header -->
            <div class="box-body">
              <table class="table table-bordered table-striped" id="example_datatable" style="width: 100%;">
                <thead>
                <tr>
                  <th>Room Code</th>
                  <th>Room type</th>
                  <th>No Of Players</th>
                  <th>Date Time</th>
                  <th>Remark</th>
                  
                </tr>
                </thead>
                <tbody>

                </tbody>
                <tfoot align="right">
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  <th></th>
                  
                </tfoot>
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
  <!-- Load common footer -->
<?php $this->load->view('common/footer'); ?>

