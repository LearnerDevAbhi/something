<!-- Load common header -->
<?php $this->load->view('common/header'); ?>

<!-- Load common left panel -->
<?php $this->load->view('common/left_panel.php'); ?>
<link rel="stylesheet" type="text/css" href="<?= base_url();?>assets/custom_css/supportChat.css">
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

         <div class="messaging ">
  <div class="inbox_msg bShow">
  <div class="inbox_people ">
    <div class="headind_srch">
    <div class="recent_heading">
      <h4>Recent</h4>
    </div>
   <!--  <div class="srch_bar">
      <div class="stylish-input-group">
      <input type="text" class="search-bar"  placeholder="Search" >
      </div>
    </div> -->
    </div>
    <div class="inbox_chat scroll cursor" id="userMsg">
    
    

  
    </div>
  </div>



  <div class="mesgs bShow">
    <div class="msg_history scrollUp" type="text" id="userChat">
  
   
    </div>
  
        <span id="errmessage" class="text-danger"><?php echo form_error('message'); ?></span>
    <div class="type_msg">
    <div class="input_msg_write">
        <input type="hidden" id="user_id" value="">
      <input type="text" class="write_msg" name="message" id="message" placeholder="Type a message" />
      <button class="msg_send_btn" type="button" id="scrollUpDown" onclick="replychat('Admin');"><i class="fa fa-paper-plane" aria-hidden="true"></i></button>
    </div>
    </div>
 
  </div>
  </div>
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
  var url = '<?= site_url(USERREPORTLIST); ?>';
  var actioncolumn=4;
  var pageLength='';
    
</script>
  <!-- Load common footer -->

<?php $this->load->view('common/footer.php'); ?>
<script type="text/javascript">

  function  replychat(Admin){
     var message =$('#message').val();
     var userId =$('#user_id').val();
     var site_url= $('#site_url').val();
     var url =site_url+'/Supports/replychat';
      if(userId==''){
            $("#errmessage").fadeIn().html("Please select users conversation.");
            setTimeout(function(){$("#errmessage").html("&nbsp;");},3000)
            $("#message").focus();
            return false;
      }
    if(message.trim() == '') {
        $("#errmessage").fadeIn().html("Please type a message.");
        setTimeout(function(){$("#errmessage").html("&nbsp;");},3000)
        $("#message").focus();
        return false;
    }
    if(userId!=''){
      var datastring ="userId="+userId+"&message="+message+"&Admin="+Admin+"&"+csrfName+"="+csrfHash;
      $.ajax({
          type:"post",
          url:url,
           data:datastring,
          success:function(returndata){
            $("#userChat").append(returndata);
            $('#message').val('');
            $.ajax({
              url: $("#site_url").val()+"/Csrfdata",
              type: "GET",
              success: function(response) {
                var obj = JSON.parse(response);
                $("#csrf_token").val(obj);
                csrfHash = obj;
              }
            });
          }
      });
    }
  }
  $(function(){
    getuserlist();
  });
  function getuserlist(){
    var site_url= $('#site_url').val();
    var url =site_url+'/Supports/getuserlist';
    var datastring =csrfName+"="+csrfHash;
      $.ajax({
          type:"post",
          url:url,
          data:datastring,
          success:function(returndata){
            $("#userMsg").html(returndata);
            $.ajax({
              url: $("#site_url").val()+"/Csrfdata",
              type: "GET",
              success: function(response) {
                var obj = JSON.parse(response);
                $("#csrf_token").val(obj);
                csrfHash = obj;
              }
            });
          }
      });
  }

  function getUserName(userId){
    $('#countIdHide'+userId).hide();
    $('.inactiveClass').removeClass('active_chat').addClass('bg-default');
    $('#userActive'+userId).addClass('active_chat').removeClass('bg-default');
    var site_url= $('#site_url').val();
    var url =site_url+'/Supports/getChat';
    var datastring ="userId="+userId+"&"+csrfName+"="+csrfHash;
    $("#user_id").val(userId);
    $.ajax({
      type:"post",
      url:url,
      data:datastring,
      success:function(returndata){
        $("#userChat").html(returndata);
        // getuserlist();
        //table.draw();
        $.ajax({
          url: $("#site_url").val()+"/Csrfdata",
          type: "GET",
          success: function(response) {
            var obj = JSON.parse(response);
            $("#csrf_token").val(obj);
            csrfHash = obj;
          }
        });
      }
    });
  }
</script>