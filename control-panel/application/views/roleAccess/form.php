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
        <li><a href="<?= site_url(ROLEACCESS); ?>"><?= $breadhead; ?></a></li>
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
                    <input type="hidden" name="id" value="<?= $id; ?>">
                    <label>Name<span class="text-danger"></span> <span class="text-danger">* </span><span id="errname" class="text-danger"></span></label>
                    <input type="text" class="form-control" name="name" id="name" placeholder="Enter Name" value="<?= $name; ?>" autocomplete="off">
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label>Email<span class="text-danger"></span> <span class="text-danger">* </span><span id="erremail" class="text-danger"></span></label>
                    <input type="text" class="form-control" name="email" id="email" placeholder="Enter Email"  value="<?= $email; ?>" autocomplete="off">
                  </div>
                </div>
                <?php if($button=="Create"){?>
                <div class="col-md-6">
                  <div class="form-group">
                    <label>Password<span class="text-danger"></span> <span class="text-danger">* </span><span id="errpassword" class="text-danger"></span></label>
                    <input type="password" class="form-control" name="password" id="password" placeholder="Enter Password"  value="<?= $password; ?>" autocomplete="off">
                  </div>
                </div>
               <?php }?>
                <div class="col-md-12" style="margin-top: 10px;">
                  <div class="form-group">
                    <input type="hidden" name="button" id="button" value="<?= $button; ?>">
                    <button type="submit" class="btn btn-primary" onclick="return validateUser()"><?= $button; ?></button>&nbsp;
                    <a href="<?= site_url(ROLEACCESS); ?>"><button type="button" class="btn btn-danger">Cancel</button></a>
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
<script type="text/javascript">
  function validateUser() {
    var name = $("#name").val();
    var password = $("#password").val();
    var email = $("#email").val();
    var email_filter = /^[a-z0-9._-]+@[a-z]+.[a-z]{2,5}$/i;
     
    if(name.trim() == '')
    {
          $("#errname").fadeIn().html("Please enter name.");
          setTimeout(function(){ $("#errname").removeClass('error'); $("#errmsg").html("&nbsp;");},3000)
          $("#name").focus();
          return false; 
    }
    if(email.trim() == '')
    {
          $("#erremail").fadeIn().html("Please enter email.");
          setTimeout(function(){ $("#erremail").removeClass('error'); $("#errmsg").html("&nbsp;");},3000)
          $("#email").focus();
          return false; 
    }
    else if(!email_filter.test(email))
    {
          $("#erremail").fadeIn().html("Please enter valid email.");
          setTimeout(function(){ $("#erremail").removeClass('error'); $("#errmsg").html("&nbsp;");},3000)
          $("#email").focus();
          return false; 
    }

    if(password.trim() == '')
    {
          $("#errpassword").fadeIn().html("Please enter password.");
          setTimeout(function(){ $("#errpassword").removeClass('error'); $("#errmsg").html("&nbsp;");},3000)
          $("#password").focus();
          return false; 
    }
  }
  
</script>
