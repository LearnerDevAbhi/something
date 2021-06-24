<!-- Load common header -->
<?php $this->load->view('common/header'); ?>
<?php $this->load->view('common/left_panel'); ?>
<!-- Load common left panel -->
<div class="content-wrapper">
<section class="content-header">
     <h1>
        <h1>
        Assign Role Access  
        <small>&nbsp;</small>
      </h1>
      </h1>
      <ol class="breadcrumb">
        <li><a href="<?= site_url(DASHBOARD)?>"><i class="fa fa-dashboard"></i>Dashboard</a></li>
        <li class="active">Manage Users</li>
      </ol>
    </section>  
    <section class="content">
        <div class="row">
            <div class="col-lg-12">
                <div class="box box-primary">
                    <?php echo form_open_multipart($action);?>
                        <div class="box-header with-border">
                            <div class="col-md-4 text-light-blue"></div>
                            <div class="col-md-4 text-danger" id="check_err"></div>
                            <div class="col-md-4 text-right" style="padding: 0px;">
                                <input type="hidden" name="adminId" id="adminId" value="<?= $adminId; ?>">
                                <a href="<?= site_url(ROLEACCESS); ?>" class="pull-right btn btn-sm btn-danger">Back</a>
                            </div>     
                        </div>
                    
                        <div class="box-body">
                            <div>
                      
                                <table class="table table-bordered table-hover" style="border: none;">
                                    <thead>
                                        <tr>
                                            <th style="width:80px" >Sr No</th>
                                            <th>Menu</th>
                                            <th>Sub Menu</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        
                                        <?php $sr=1; foreach($getmenus as $row) {

                                            $getSubMenu = $this->RoleAccess_model->GetData('admin_menus','',"parentId='".$row->menuId."' and type='SUBMENU'");

                                            ?>
                                            <tr>
                                                <td><?= $sr; ?></td>
                                                    
                                                <td>
                                                    <input <?= ( isset($selected_menu_id) &&  in_array($row->menuId, $selected_menu_id)) ? 'checked':'';  ?> type="checkbox" name="menu[]" id="mainCheckBox" class="mainCheckBox" value="<?= $row->menuId ?>">&nbsp; <?= ucfirst($row->menuName); ?>

                                                </td>

                                                <td>
                                                <?php if(!empty($getSubMenu)) { 
                                                    $subSr = 1;


                                                    foreach ($getSubMenu as $subMenu) { ?>
                                                        <span>
                                                            <?= $subSr; ?> ) &nbsp; <input <?= ( isset($selected_submenu_ids) &&  in_array($subMenu->menuId, $selected_submenu_ids)) ?'checked':'';?> type="checkbox" name="submenu[]" id="subMenusCheckBox" value="<?= $subMenu->menuId ?>">&nbsp; <?= ucfirst($subMenu->menuName); ?>
                                                        </span><br/>
                                                
                                                <?php $subSr++; } } ?>

                                                </td>

                                            </tr>
                                        <?php $sr++; } ?>


                                    </tbody>    
                                </table>
                                <button type="submit" onclick="return validation()" class="btn btn-success">Submit</button>
                                <span id="error_select_checkbox"></span>
                           
                            </div>
                        </div>
                    <?= form_close();?>
                </div> 
            </div>
        </div>
    </section>
</div>
 <!-- Load common footer -->
<?php $this->load->view('common/footer'); ?>


<script type="text/javascript">
    
function validation()
{
    flag = 0;
    $("input[type=checkbox]").each(function()
    {

        if($(this).is(':checked'))
        {
                 flag = 1;
                 return false;
        }
    });

    if(flag==0)  
    {
        $("#check_err").fadeIn().html("Please check atleast 1 checkbox");
        setTimeout(function(){$("#check_err").fadeOut("&nbsp");},5000)
        $("#check_err").focus();
        return false;
    }
    
}
</script>


