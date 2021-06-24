<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Join_model  extends CI_Model
{
    function __construct()
    {
        parent::__construct();

    }
    
 public function get_Academy_data($cond='')
 {
 	$this->db->select('pro.id as pro_id,pro.title as pro_title,price,pro.image as pro_image,duration,acd.id as acd_id,acd.title as acd_title,ban.id as ban_id,ban.banner_title as ban_title,cat.id as cat_id,cat.title as cat_title,sub.id as sub_id,sub.sub_category_title as sub_title');
 	$this->db->from('products as pro'); 
 	$this->db->join('mst_academics as acd','acd.id=pro.academic_id','left'); 
 	$this->db->join('categories as cat','cat.id=pro.category_id','left'); 
 	$this->db->join('banners as ban','ban.id=cat.category_banner','left');  
 	$this->db->join('sub_categories as sub','sub.id=pro.sub_category_id','left'); 
 	$this->db->order_by('pro_title');
 	$this->db->limit('10');
 	if($cond!='') $this->db->where($cond);
 	return $this->db->get()->result();
 }

}