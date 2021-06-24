<!-- Load common header -->
<?php $this->load->view('common/header'); ?>
<?php $this->load->view('common/left_panel'); ?>
  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1><?= $heading; ?>
      </h1>
      <ol class="breadcrumb">
        <li><a href="<?= site_url(DASHBOARD); ?>"><i class="fa fa-dashboard"></i> Dashboard</a></li>
        <li><a href="<?= site_url(SPINROLL); ?>"><?= $breadhead; ?></a></li>
        <li><?= $bread; ?></li>
      </ol>
    </section>

    <!-- Main content -->
    <section class="content">
      <div class="row">
        <div class="col-xs-12">

          <div class="box bShow">
            <div class="box-header">
              <div class="col-md-10 box-title"><?= $heading; ?></div>
              <div class="col-md-2 text-right text-danger">* Fields are required</div>
            </div>
            <!-- /.box-header -->
            <?php echo form_open($action); ?>
              <div class="box-body">
                <div class="col-md-6">
                  <div class="form-group">
                    <label>Title<span class="text-danger"></span> <span class="text-danger">* </span><span id="errtitle" class="text-danger"><?= strip_tags(form_error('title')); ?></span></label>
                    <input type="text" class="form-control" name="title" id="title" value="<?= $title;?>" placeholder="Title"  autocomplete="off">
                  </div>
                </div>

                <div class="col-md-6">
                  <div class="form-group">
                    <label>Value<span class="text-danger"></span> <span class="text-danger">* </span><span id="errvalue" class="text-danger"><?= strip_tags(form_error('value')); ?></span></label>
                    <input type="text" class="form-control" name="value" id="value" value="<?= $value;?>" placeholder="Value"  autocomplete="off" onkeypress="only_number(event)">
                  </div>
                </div>

                <div class="form-group col-md-6">
                  <label for="status">Status</label>    
                  <br>  
                   <input type="radio" checked="checked" name="status" value="Active" <?php if($status=='Active'){ echo 'checked';}?>>&nbsp;&nbsp;Active
                   <input type="radio" name="status" value="Inactive" <?php if($status=='Inactive'){echo 'checked';}?>>&nbsp;&nbsp;Inactive   
                </div>

                <div class="col-md-12" style="margin-top: 10px;">
                  <div class="form-group">
                    <input type="hidden" name="id"  value="<?= $id; ?>">
                    <input type="hidden" name="button" id="button" value="<?= $button; ?>">
                    <button type="submit" class="btn btn-primary" onclick="return valid();"><?= $button; ?></button>&nbsp;
                    <a href="<?= site_url(SPINROLL); ?>"><button type="button" class="btn btn-danger">Cancel</button></a>
                  </div>
                </div>
                
              </div>
              <!-- /.box-body -->
            <?php echo form_close(); ?>
            <!-- </form> -->
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
<script type="text/javascript" src="<?= base_url(); ?>/assets/custom_js/spinRoll.js"></script>