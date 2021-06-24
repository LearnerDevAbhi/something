<!-- Load common header -->
<?php $this->load->view('common/header'); ?>
<!-- Load common left panel -->
<link rel="stylesheet" href="<?php echo base_url();?>assets/datepicker/jquery-ui.css">
<style type="text/css">
  .error
  {
    color:red;
  }
</style>
<?php $this->load->view('common/left_panel'); ?>
  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1><?= $heading; ?>
      </h1>
      <ol class="breadcrumb">
        <li><a href="<?= site_url(DASHBOARD); ?>"><i class="fa fa-dashboard"></i> Dashboard</a></li>
        <li><a href="<?= site_url(BOTPLAYER); ?>"><?= $breadhead; ?></a></li>
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
           <?php echo form_open_multipart($action); ?>
                 <input type="hidden" name="id" value="<?= $id; ?>">
              <div class="box-body">
                <div class="form-group col-md-6">
                  <label for="user_name">User Name<span class="text-danger"> * </span>
                  <span id="user_name_err" class="text-danger"><?= strip_tags(form_error('user_name')); ?></span></label>
                     
                  <input type="text" class="form-control" name="user_name" id="user_name" placeholder="User Name" value="<?= $user_name;?>" autocomplete="off"/>
                </div>

                 <div class="form-group col-md-6">
                  <label for="country_name">Country Name<span class="text-danger"> * </span>
                  <span id="country_name_err" class="text-danger"><?= strip_tags(form_error('country_name')); ?> </span></label>
                  <input type="text" class="form-control" name="country_name" id="country_name" placeholder="Country Name" value="<?= $country_name;?>" autocomplete="off"/>  
                </div>

                <!-- <div class="form-group col-md-6">
                  <label for="balance">Balance<span class="text-danger"> * </span>
                  <span id="balance_err" class="text-danger"><?= strip_tags(form_error('balance')); ?></span></label>
                  <input type="text" onkeypress="only_number(event)" class="form-control" name="balance" id="balance" placeholder="Balance" value="<?= $balance;?>" autocomplete="off"/>  
                </div> -->
                <input type="hidden" onkeypress="only_number(event)" class="form-control" name="balance" id="balance" placeholder="Balance" value="1000" autocomplete="off"/>  
                  <?php if($button=="Create"){ ?>
                <div class="form-group col-md-6">
                  <label for="profile_img">Profile Image<span class="text-danger"> * </span>
                  <span id="profile_img_err" class="text-danger"><?= strip_tags(form_error('profile_img')); ?></span></label>
                  <input type="file" class="form-control" name="profile_img" id="profile_img" value="" onclick="return ImageFile();"/>
                  <span class="text-primary">Note : Please select jpg, png, jpeg type of image</span>  
                </div>
                  <?php } ?>
                  

                 <?php if($button=="Update"){ ?>
                  <div class="form-group col-md-6">
                    <label for="profile_img">Profile Type <span class="text-danger"> * </span>&nbsp;&nbsp;&nbsp;&nbsp;</label>
                    <span class="text-primary">Note : Please select jpg, png, jpeg type of image</span>
                     <input type="file" class="form-control" name="profile_img"  id="profile_img"/>
                    <!--    <small>Features image size shoddduld be 1440*500 px.</small> -->
                    <div><img src="<?= base_url('uploads/userProfileImages/'.$profile_img);?>" width="50px"></div>
                    <input type="hidden" name="old_photo" id="old_photo" value="<?=$profile_img;?>">
                  </div>
                  <?php } ?>
                </div>  
                  <!-- status start -->
                  <?php 
                    $active="";$inactive="";
                    if($status=='Inactive')  $inactive="checked";
                    else if($status=='Active') $active="checked";
                  ?>  
                <div class="form-group col-md-6">
                  <label for="status">Status&nbsp;&nbsp;&nbsp;&nbsp;</label>
                  <span class="error" id="type_err"></span>
                  <?=  form_error('status'); ?>
                   <?= $this->session->flashdata('php_error'); ?> 
                  <br/>
                   <input type="radio"   <?= $active; ?> <?php  set_radio('status','Active',FALSE); ?> name="status" value='Active' checked/>&nbsp;&nbsp;Active
                   <input type="radio"   <?= $inactive; ?> <?php  set_radio('status','Inactive',FALSE); ?> name="status" value='Inactive' />&nbsp;&nbsp;Inactive   
                </div>
              <!-- </div>   -->

              <div class="clearfix"></div>
              <!-- /.box-body -->
              <div class="box-footer">
                  <input type="hidden" id="button" value="<?php echo $button; ?>"/>
                 <button type="submit" onclick="return valid();" class="btn btn-primary"><?= $button;?></button> 
                <a type="button" href="<?= site_url(BOTPLAYER); ?>" class="btn btn-danger">Cancel</a>
              </div> 
            <!-- </form> -->
            <!-- /.box-body -->
          </div>
        <?= form_close(); ?>
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
<script type="text/javascript" src="<?= base_url(); ?>assets/custom_js/botPlayer.js"></script>

