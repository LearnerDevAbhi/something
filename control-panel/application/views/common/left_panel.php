<?php 
	 // $page = $this->uri->segment(1);
	 // $split = explode('-', $page);
	 // //print_r($page);exit;
	 
	 // $flag = $this->uri->segment(2);
	 // print_r($flag);exit;
	 $getProfile = $this->Crud_model->GetData("admin_login",'image','id="'.$_SESSION[SESSION_NAME]['id'].'"','','','','1');

	$page = $this->uri->segment(1);
	$split = explode('-', $page);
	 
	$flag = $this->uri->segment(2);
	$getProfile = $this->Crud_model->GetData("admin_login",'image','id="'.$_SESSION[SESSION_NAME]['id'].'"','','','','1');
	if($_SESSION[SESSION_NAME]['role']=='Admin'){
	    $allMenuData = $this->Crud_model->getMenuData();
	}else{
	    $id = $_SESSION[SESSION_NAME]['id'];
	    $allMenuData = $this->Crud_model->userMenuData($id);
	}
	 ?>
<!-- Left side column. contains the logo and sidebar -->
<aside class="main-sidebar">
	 <!-- sidebar: style can be found in sidebar.less -->
	 <section class="sidebar">
			<!-- Sidebar user panel -->
			<div class="user-panel">
				 <div class="pull-left image">
						<?php
							 $image = $getProfile->image;
							 $path = "assets/images/profile/";
							 $file = FCPATH.$path.$image;
							 if(file_exists($file) && !empty($image))
							 {
								 $img = base_url().$path.$image;
							 }
							 else
							 {
								 $img = base_url().$path."profile.png";
							 }
							 ?>
						<img src="<?= $img; ?>" class="img-circle" alt="User Image">
				 </div>
				 <div class="pull-left info">
						<p><?php echo $_SESSION[SESSION_NAME]['name'];?></p>
						<a href="#"><i class="fa fa-circle text-success"></i> Online</a>
				 </div>
			</div>
			<!-- sidebar menu: : style can be found in sidebar.less -->
			<ul class="sidebar-menu" data-widget="tree">
			<?php if(!empty($allMenuData)){ foreach($allMenuData as $menu){
          if($menu['countChild']==0){ ?>

          <li class="<?php if($split[0]==$menu['mainConstant']) echo " active"; ?>">
            <a href="<?php echo site_url($menu['mainConstant']); ?>">
              <i class="<?= $menu['mainIcon']?>"></i><span> <?= $menu['menuName'];?></span>
            </a>
          </li>
          <?php }else{
              $subMenu = explode(',', $menu['menuConstant']); 
              $subMenuName = explode(',', $menu['subMenuName']); 
              $subMenuIcon = explode(',', $menu['menuIcon']); 
          ?>
          <li class="treeview <?php if(in_array($split[0],$subMenu)) echo " active"; ?>">
          <a href="javascript:void(0)">
            <i class="<?= $menu['mainIcon']?>"></i> <span><?= $menu['menuName'];?></span>
            <span class="pull-right-container">
              <i class="fa fa-angle-left pull-right"></i>
            </span>
          </a>
          <ul class="treeview-menu <?php if(in_array($split[0],$subMenu)) echo " active"; ?>">
            <?php 
            foreach ($subMenu as $key => $sub) { ?>
              <li class="<?php if($split[0]==$subMenu[$key]) echo " active"; ?> ">
                <a href="<?php echo site_url($subMenu[$key]); ?>">
                  <i class="<?= $subMenuIcon[$key]?>"></i><span> <?= $subMenuName[$key]?></span>
                </a>
              </li>
            <?php }?>
          </ul>
        </li>
        <?php } } }?>
		</ul>
	 </section>
	 <!-- /.sidebar -->
</aside>