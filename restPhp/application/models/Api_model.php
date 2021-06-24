<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Api_model extends CI_Model
{
    function __construct()
    {
        parent::__construct();
    }
    
     public function GetData($table,$field='',$condition='',$group='',$order='',$limit='',$result='')
    {
        if($field != '')
        $this->db->select($field);
        if($condition != '')
        $this->db->where($condition);
        if($order != '')
        $this->db->order_by($order);
        if($limit != '')
        $this->db->limit($limit);
        if($group != '')
        $this->db->group_by($group);
        if($result != '')
        {
            $return =  $this->db->get($table)->row();
        }else{
            $return =  $this->db->get($table)->result();
        }
        return $return;
    }
  
    public function SaveData($table,$data,$condition='')
    {
        $DataArray = array();
        if(!empty($data))
        {
            $data['created']=date("Y-m-d H:i:s");
            $data['modified']=date("Y-m-d H:i:s");
        }
        $table_fields = $this->db->list_fields($table);
        foreach($data as $field=>$value)
        {
            if(in_array($field,$table_fields))
            {
                $DataArray[$field]= $value;
            }
        }
       
        if($condition != '')
        {
            $this->db->where($condition);
            return $this->db->update($table, $DataArray);
        }else{
            return $this->db->insert($table, $DataArray);
        }
    }

    public function DeleteData($table,$condition='',$limit='')
    {
       if($condition != '')
        $this->db->where($condition);
        if($limit != '')
        $this->db->limit($limit);
        return $this->db->delete($table);
    }

    public function multijoin($table,$field='',$condition='',$group='',$order='',$limit='',$tables='',$joincon='',$jointype='',$result='')
    {
        if($field != '')
        $this->db->select($field);
        if($condition != '')
        $this->db->where($condition);
        if($order != '')
        $this->db->order_by($order);
        if($limit != '')
        $this->db->limit($limit);
        if($group != '')
        $this->db->group_by($group);

        for ($i=0; $i <count($tables); $i++)
        {
            $this->db->join($tables[$i], $joincon[$i],$jointype[$i]);
        }
        if($result != '')
        {
            $return =  $this->db->get($table)->row();
        }else{
            $return =  $this->db->get($table)->result();
        }
        return $return;
    }
    
    public function getCategoryProducts($cond)
    {
        $this->db->select('products.title,products.price,medias.actual_image');
        $this->db->from('products');
        $this->db->join('medias','medias.id=products.media_id','left'); 
        $this->db->where($cond);
        $query = $this->db->get();
        return $query->result();
    }

    public function cart_detail($con)
    {
        $this->db->select('tc.*,p.title,m.small_url,p.id as product_id');
        $this->db->from('temp_cart_items tc');
        $this->db->join('products p','p.id=tc.product_id','left'); 
        $this->db->join('medias m','m.id=p.media_id','left'); 
        $this->db->where($con);
        $query = $this->db->get();
        return $query->result();
    }

    public function GetCustomerBillingData($condition)
    {
        $this->db->select('s.username,s.email,ctr.country_name,st.state_name,cc.city_name,s.pincode,s.land_mark,s.mobile,s.address');
        $this->db->from('students s');
        $this->db->join('countries ctr','ctr.id=s.country_id','left');
        $this->db->join('cities cc','cc.id=s.city_id ','left');
        $this->db->join('states st','st.id=s.state_id ','left'); 
        $this->db->where($condition);
        $query = $this->db->get();
        return $query->row();
    }

    public function max_order_no()
    {
        $this->db->select('MAX(id) as m');
        $this->db->from('orders');
        $query = $this->db->get();
        return $query->row();
    }

    public function view_order($condition)
    {
        $this->db->select('p.id as prod_id,p.title,p.type,od.price,od.order_details_quantity,od.order_details_total_price,od.product_varient_id,od.product_video_link,m.small_url');
        $this->db->from('orders o');
        $this->db->join('order_details od','od.order_id=o.id','left'); 
        $this->db->join('products p', 'p.id=od.product_id', 'left');
        $this->db->join('medias m','m.id=p.media_id','left');
        $this->db->where($condition);
        $query = $this->db->get();
        return $query->result();
    }

    public function cust_address($condition)
    {
        $this->db->select('a.*,c.country_name,s.state_name,ct.city_name,st.email');
        $this->db->from('address a');
        $this->db->join('students st','a.customer_id=st.id','left'); 
        $this->db->join('countries c','a.country_id=c.id','left'); 
        $this->db->join('states s', 's.id=a.state_id', 'left');
        $this->db->join('cities ct','ct.id=a.city_id','left');
        $this->db->where($condition);
        $query = $this->db->get();
        return $query->row();
    }


    public function allProducts($cond = '',$if_exist="")
    {  
         
        if($cond!='')
        {    
            $this->db->where($cond);
        }
        $this->db->select('p.id as product_id,p.title,price,f.title as faculty_name,p.image as productImage,subj.subject as subject,acad.title as academy'.$if_exist);
        $this->db->from('products p');
        $this->db->join('faculties f','f.id=p.faculty_id','left'); 
        //$this->db->join('medias m','m.id=p.media_id','left'); 
        $this->db->join('categories cat','cat.id=p.category_id','left'); 
        $this->db->join('mst_subjects subj', 'subj.id=p.subject_id', 'left');
        $this->db->join('faculties fact','fact.id=p.faculty_id','left');
        $this->db->join('mst_academics acad','acad.id=p.academic_id','left');
        $this->db->limit('9');
        $query = $this->db->get();
        return $query->result();
    }


    public function student_also_purchase($cond='',$if_exist='')
    {
        if($cond!='')
        {
            $this->db->where($cond);
        }
        $this->db->select('p.id as product_id,p.title,p.price,p.duration,p.image as productImage,f.title as faculty_name,subj.subject as subject,acad.title as academy'.$if_exist);
        $this->db->from('products p');
        $this->db->join('faculties f','f.id=p.faculty_id','left'); 
        $this->db->join('order_details od','od.product_id=p.id','left'); 
        $this->db->join('categories cat','cat.id=p.category_id','left'); 
        $this->db->join('mst_subjects subj', 'subj.id=p.subject_id', 'left');
        $this->db->join('faculties fact','fact.id=p.faculty_id','left');
        $this->db->join('mst_academics acad','acad.id=p.academic_id','left');
        $this->db->group_by('od.product_id');
        $query = $this->db->get();
        return $query->result();
    }

    public function ProductsRow($cond='',$if_exist='')
    {
        if($cond!='')
        {
            $this->db->where($cond);
        }
        $this->db->select('p.id,p.category_id,p.title,p.short_description,p.long_description as description,p.price,p.validity,p.image,p.product_info,p.type,p.status,f.title as faculty,f.description as about_the_faculty,p.image as productImage,subj.subject as subject,acad.title as academy'.$if_exist);
        $this->db->from('products p');
        $this->db->join('faculties f','f.id=p.faculty_id','left');  
        //$this->db->join('medias m','m.id=p.media_id','left'); 
        $this->db->join('categories cat','cat.id=p.category_id','left'); 
        $this->db->join('mst_subjects subj', 'subj.id=p.subject_id', 'left');
        $this->db->join('faculties fact','fact.id=p.faculty_id','left');
        $this->db->join('mst_academics acad','acad.id=p.academic_id','left');
        $query = $this->db->get();
        return $query->row();
    }

     public function category_products($con)
    {
        $this->db->select('products.*');
        $this->db->from('products'); 
        $this->db->where($con);
        $query = $this->db->get();
        return $query->result();
    }


    public function get_field()
    {
        $this->db->select('column_name');
        $this->db->from("information_schema.columns");
        $this->db->where("table_schema = 'eduprof' and table_name = 'products' and column_name like '%_price'"); 
        $query = $this->db->get();
        return $query->result();
   
/*
        $this->db->query("select column_name from information_schema.columns where table_schema = 'eduproof' and table_name = 'products' and column_name like '%price%';");  
        $query = $this->db->get();
        return $query->result();
select column_name from information_schema.columns where table_schema = 'db_name' and table_name = 'table_name' and column_name like '%price%';
         */
    }

   function  select_insert($table1,$table2,$cond)
   {
        $final_amount=0;  
        $select=$this->db->where($cond)->get($table1)->result(); 
          //  print_r($select); exit; 
     //   print_r($this->db->last_query()); exit; 
        if(empty($select)) return 'null';  
        foreach ($this->db->where($cond)->get($table1)->result() as $fields) {
   
  $this->DeleteData('cart_items','customer_id="'.$fields->customer_id.'" and product_id="'.$fields->product_id.'" '); 

   
        $insert_data=array(
            'product_id'=>$fields->product_id, 
            'customer_id'=>$fields->customer_id,
            'delivery_method'=>$fields->delivery_method,
            'delivery_method_price'=>$fields->delivery_price,
            'temp_customer_id'=>$fields->temp_customer_id,
            'quantity'=>$fields->quantity,
            'product_price'=>$fields->product_price,
            'final_price'=>$fields->final_price,
            'cart_date'=>$fields->cart_date,
            'created'=>$fields->created,
            'modified'=>$fields->modified, 
        );
        $final_amount+=$fields->final_price;
         $this->db->insert($table2,$insert_data); 

 
        } 

           return $final_amount; 
   
   }


   function select_insert2($from_table,$to_table,$cond,$order_no)
   {
        $select=$this->db->select()->where($cond)->get($from_table)->result(); 
 
    $payment_logs= $this->Admin_model->GetData("payment_logs",'',"order_no='".$order_no."'",'','','','single');

    $oid=0;
    $oidArr=$this->Admin_model->GetData("orders","id","order_no='".$order_no."'","","","","1");
    if(!empty($oidArr))
    {
        $oid=$oidArr->id;   
    }
 

if(empty($payment_logs))
{
    $order_no="";
}
else
{
    $order_no=$payment_logs->order_no;

}
        foreach ($select as $value) {
$products=$this->GetData("products",'price,quantity,id,type,video',"id='".$value->product_id."'","","","","1");
              

          if($products->type == 'Pendrive') 
          {
              $product_video_link="";
          }  
          else
          {
              $product_video_link=base_url('/admin/uploads/product_video/'.$products->video) ;
          }  

            $data=array(
                'order_id'=>$oid,    
                'delivery_method'=>$value->delivery_method,
                'delievery_method_price'=>$value->delivery_method_price,
                'product_id'=>$value->product_id,
                'price'=>$value->product_price,
                'product_video_link'=>$product_video_link, 
                'order_details_total_price'=>$value->final_price,
                'order_details_quantity'=>$value->quantity,
                'created'=>date('Y-m-d h:i:s')
            );
            $this->db->insert($to_table,$data); 
  
            if($products->type == 'Pendrive') 
            {

              $minus_quantity=$products->quantity - $value->quantity;
                
              $data=array(
                    'quantity' =>$minus_quantity,
                  );
                 $this->Admin_model->SaveData("products",$data,"id='".$products->id."'");

                  $stock_data=array(
                  'product_id'=>$products->id,
                  'perticular'=>'Sale',
                  'quantity'=>$value->quantity,
                  'available_quantity'=>$minus_quantity,
                  'order_no'=>$order_no,  
                  'date'=>date("Y-m-d H:i:s"),
                  );
                  $this->Admin_model->SaveData('stock_logs',$stock_data);
             }

        }
   }

   
     
} 
?>