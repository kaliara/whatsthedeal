ActionController::Routing::Routes.draw do |map|

  # old urls
  map.connect 'deal/access/:deal_id/:user_id', :controller => 'coupons', :action => 'legacy', :requirements => {:protocol => "http"}
  map.connect 'deal/:slug',            :controller => 'promotions', :action => 'index'
  map.connect 'info/how_it_works',   :controller => 'static', :action => 'how_it_works', :requirements => {:protocol => "http"}
  map.connect 'info/faq',            :controller => 'static', :action => 'faq', :requirements => {:protocol => "http"}
  map.connect 'info/press',          :controller => 'static', :action => 'press', :requirements => {:protocol => "http"}
  map.connect 'promo',               :controller => 'static', :action => 'signup', :requirements => {:protocol => "http"}

  # partner purchases
  #map.connect 'sloopy',      :controller => 'partner_purchases', :action => 'home'
  #map.connect 'sloopy_info', :controller => 'partner_purchases', :action => 'how_it_works'
  map.connect '/teampick',          :controller => 'partner_purchases', :action => 'home'
  map.connect '/teampick/checkout', :controller => 'partner_purchases', :action => 'checkout'

  # carts, gifts and accounts
  map.my_cart          'my_cart',          :controller => 'carts',   :action => 'show'
  map.my_account       'my_account',       :controller => 'users',   :action => 'show', :tab => 'personal'  
  map.my_account_email 'my_account_email', :controller => 'users',   :action => 'show', :tab => 'email'  
  map.edit_my_account  'edit_my_account',  :controller => 'users',   :action => 'edit'
  map.my_deals         'my_deals',         :controller => 'coupons', :action => 'index' 
  map.my_deals_used    'my_deals/used',    :controller => 'coupons', :action => 'index', :show_all => 'used'
  map.my_deals_expired 'my_deals/expired', :controller => 'coupons', :action => 'index', :show_all => 'expired'
  map.my_deals_gifts   'my_deals/gifts',   :controller => 'coupons', :action => 'index', :show_all => 'gifts'
  map.edit_gift_item   'edit_gift/:id',    :controller => 'cart_items', :action => 'edit_gift_item'
  map.edit_coupon_gift   'edit_coupon_gift/:id',   :controller => 'coupons', :action => 'edit_gift'
  map.update_coupon_gift 'update_coupon_gift/:id', :controller => 'coupons', :action => 'update_gift'
  map.gift               '/gift/:token',           :controller => 'coupons', :action => 'show_gift'
  map.buy_credit         '/promotions/buy_credit', :controller => 'promotions', :action => 'buy_credit'
  map.coupon_shipping_details '/coupons/:id/shipping_details', :controller => 'coupons', :action => 'shipping_details'
  
  # credits
  map.credits '/credits', :controller => 'credits', :action => 'create'
  map.redeem_gifted_credit '/credits/redeem_gift/:code', :controller => 'credits', :action => 'redeem_gift'

  # reminders
  map.quick_reminder '/add_reminder/:reminder_promotion_id/:from_index', :controller => 'reminders', :action => 'create'
  map.connect '/add_reminder/:reminder_promotion_id',             :controller => 'reminders', :action => 'create', :from_index => false

  # referral links  
  map.referral  'referral/:code',              :controller => 'users', :action => 'referral_signup'
  map.referrals 'ref/:code',                   :controller => 'users', :action => 'referral_signup'
  map.referral_signup 'referral_signup/:code', :controller => 'users', :action => 'referral_signup'
  
  # map
  map.promotion_map '/promotions/map', :controller => 'promotions', :action => 'map'
  map.set_location '/users/set_location', :controller => 'users', :action => 'set_location'
  map.clear_location '/users/clear_location', :controller => 'users', :action => 'clear_location'
  
  # auction
  map.charity 'charity',  :controller => 'items',  :action => 'index', :requirements => {:protocol => "http"}
  map.item '/items/:id', :controller => 'items', :action => 'show', :requirements => {:protocol => "http"}
  map.place_bid '/bid/create', :controller => 'bids', :action => 'create', :requirements => {:protocol => "http"}

  # raffles
  map.create_raffle_entry '/raffle/:id/enter', :controller => 'entries', :action => 'create'
  map.raffle '/raffles/:id', :controller => 'raffles', :action => 'show', :requirements => {:protocol => "http"}
  map.raffles '/raffles', :controller => 'raffles', :action => 'index', :requirements => {:protocol => "http"}
  map.admin_raffle_entrants '/admin/raffles/:id/entrants', :controller => 'admin/raffles', :action => 'entrants'

  # tracking codes
  map.connect '/ptc/:code',                  :controller => 'promotions', :action => 'home',    :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'promotions/ptc/:code',        :controller => 'promotions', :action => 'index',   :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'promotions/:slug/ptc/:code/', :controller => 'promotions', :action => 'show',    :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'signup/ptc/:code',            :controller => 'static',     :action => 'signup',  :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'signup2/ptc/:code',           :controller => 'static',     :action => 'signup2', :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'signup3/ptc/:code',           :controller => 'static',     :action => 'signup3', :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'signup4/ptc/:code',           :controller => 'static',     :action => 'signup4', :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'register/ptc/:code',          :controller => 'users',      :action => 'new',     :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'events/:id/ptc/:code',        :controller => 'events',     :action => 'show',    :ptc => true, :requirements => {:protocol => "http"}
  map.connect 'events/ptc/:code',            :controller => 'events',     :action => 'index',   :ptc => true, :requirements => {:protocol => "http"}
  
  # subscribe
  map.subscribe 'subscribe', :controller => 'users', :action => 'create', :quietly_create => true
  map.event_signup 'events/:id/signup', :controller => 'events', :action => 'signup'
  map.create_event_attendee '/event/attendee', :controller => 'attendees', :action => 'create', :return_uri => '/my_account'
  map.nova_simple_signup '/nova/signup', :controller => 'delayed_subscriptions', :action => 'create', :list => User::VIRGINIA_DEAL_LIST, :referrer => 'nova_email' 
  map.somd_simple_signup '/submd/signup', :controller => 'delayed_subscriptions', :action => 'create', :list => User::MARYLAND_DEAL_LIST, :referrer => 'submd_email' 
  
  # registration
  map.register 'register', :controller => 'users', :action => 'new'
  map.quiet_create_user '/users/quiet_create', :controller => 'users', :action => 'create', :quietly_create => true
  map.connect '/customers/new', :controller => 'users', :action => 'new'
  map.connect '/promo_signup/:slug', :controller => 'promotions', :action => 'show', :promo_signup => 'yes'

  # sessions and passwords
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.login  'login',  :controller => 'user_sessions', :action => 'new'
  map.forgot_password 'forgot_password',       :controller => 'users', :action => 'forgot_password'
  map.reset_password  'reset_password/:id',    :controller => 'users', :action => 'new_password'
  map.change_password '/users/change_password',:controller => 'users', :action => 'change_password'
  
  # errors
  map.timeout_error '/timeout_error', :controller => 'static', :action => 'timeout_error'
  
  # xml bits
  map.featured 'featured.:format', :controller => 'promotions', :action => 'show', :dc_featured => true
  map.arlnow 'arlnow.:format', :controller => 'promotions', :action => 'show', :arlnow => true
  map.connect  'rss.:format',      :controller => 'promotions', :action => 'rss'
  map.connect '/promotions/ad_preview.:format', :controller => 'promotions', :action => 'ad_preview'
  map.connect 'lon.:format', :controller => 'promotions', :action => 'lon'

  # cities
  map.nova '/dc', :controller => 'promotions', :action => 'show', :region => 1
  map.nova '/nova', :controller => 'promotions', :action => 'show', :region => 2
  map.set_region '/set_region', :controller => 'application', :action => 'set_region', :conditions =>  {:method => :post}
  
  # promotions
  map.grab_bag '/promotions/grab_bag', :controller => 'promotions', :action => 'grab_bag'
  map.promotions_nova '/promotions/nova', :controller => 'promotions', :action => 'index', :city_id => 2
  map.promotions_submd '/promotions/submd', :controller => 'promotions', :action => 'index', :city_id => 3
  map.promotion_slug '/promotions/:slug', :controller => 'promotions', :action => 'show' 

  # businesses stuff
  map.connect '/business/purchases/bulk_use', :controller => '/business/purchases', :action => 'bulk_use'
  map.connect '/business/purchases',:controller => '/business/purchases', :action => 'index'
  map.connect '/business/purchases/export',:controller => '/business/purchases', :action => 'export'
  map.connect '/business/mobile_redemptions/:promotion_id',:controller => '/business/purchases', :action => 'mobile_redemptions'
  map.connect '/business/purchases_stats/:promotion_id',   :controller => '/business/purchases', :action => 'stats'
  map.business_mobile_redemptions '/business/mobile_redemptions', :controller => 'business/purchases', :action => 'mobile_redemptions'
  map.business_purchase_stats '/business/purchases_stats', :controller => 'business/purchases', :action => 'stats'
  map.connect '/business', :controller => 'business/home', :action => 'index'
  map.connect '/biz', :controller => 'business/home', :action => 'index'
  map.business_home '/business/home', :controller => 'business/home', :action => 'index'
  map.business_sammple_coupon '/business/coupons/sample', :controller => 'business/coupons', :action => 'show'
  map.namespace :business do |business|
    business.resources :purchases
    business.resources :promotions
    business.resources :subscribers
    business.resources :business_staffs
  end

  # special promotion show for businesses
  map.special_preview '/promotions/:slug/:password', :controller => 'promotions', :action => 'show'
  map.event_preview   '/events/:id/:password', :controller => 'events', :action => 'show'

  # admin stuff
  map.admin_home '/admin', :controller => 'admin/home', :action => 'index'
  map.admin_dashboard '/admin/dashboard', :controller => 'admin/home', :action => 'dashboard'
  map.admin_impersonate '/admin/impersonate/:type/:id', :controller => 'admin/home', :action => 'impersonate'
  map.admin_newsletters '/admin/newsletters', :controller => 'admin/newsletters', :action => 'setup'
  map.admin_event_preview '/admin/events/preview/:id', :controller => 'admin/events', :action => 'preview'
  map.admin_event_sidebar_preview '/admin/events/sidebar_preview/:id', :controller => 'admin/events', :action => 'sidebar_preview'
  map.admin_event_rsvp_list '/admin/events/:id/rsvp_list', :controller => 'admin/events', :action => 'rsvp_list'
  map.admin_coupon_codes '/admin/deals/coupon_codes/:deal_id', :controller => 'admin/deals', :action => 'coupon_codes'
  map.admin_sample_coupon '/admin/coupons/sample/:sample_for_deal', :controller => 'admin/coupons', :action => 'show'
  map.admin_credit_profile '/admin/users/credit_profile', :controller => 'admin/users', :action => 'credit_profile'
  map.admin_promotion_activate_coupons '/admin/promotions/:id/activate_coupons', :controller => '/admin/promotions', :action => 'activate_coupons'
  map.admin_deal_activate_coupons '/admin/deals/:id/activate_coupons', :controller => '/admin/deals', :action => 'activate_coupons'
  map.admin_activate_coupons '/admin/coupons/:id/activate_coupons', :controller => '/admin/coupons', :action => 'activate_coupons'
  map.admin_dashboards '/admin/dashboards', :controller => '/admin/dashboards', :action => 'index'
  map.admin_dashboard_daily_csv '/admin/dashboards/daily.csv', :controller => '/admin/dashboards', :action => 'data', :format => 'csv', :days => '1'
  map.admin_dashboard_weekly_csv '/admin/dashboards/weekly.csv', :controller => '/admin/dashboards', :action => 'data', :format => 'csv', :days => '7'
  map.admin_promotions_dashboard '/admin/dashboards/promotions', :controller => '/admin/dashboards', :action => 'promotions'
  map.admin_earnout_dashboard '/admin/dashboards/earn_out', :controller => '/admin/dashboards', :action => 'earn_out'
  map.admin_washingtonian_dashboard '/admin/dashboards/washingtonian', :controller => '/admin/dashboards', :action => 'washingtonian'
  map.admin_affiliates_dashboard '/admin/dashboards/affiliates', :controller => '/admin/dashboards', :action => 'affiliates'
  map.admin_affiliate_lifetime_dashboard '/admin/dashboards/affiliate_lifetime', :controller => '/admin/dashboards', :action => 'affiliate_lifetime'
  map.admin_source_report_dashboard '/admin/dashboards/source_report', :controller => '/admin/dashboards', :action => 'source_report'
  map.admin_sidebar_promotions '/admin/promotions/sidebar', :controller => '/admin/promotions', :action => 'sidebar'
  map.admin_promotions_sort '/admin/promotions/sort/:city_id', :controller => '/admin/promotions', :action => 'sort'
  map.admin_promotion_codes_unlist '/admin/promotion_codes/unlist', :controller => '/admin/promotion_codes', :action => 'unlist'
  map.admin_origin_associate_business '/admin/origins/associate_business', :controller => '/admin/origins', :action => 'associate_business'
  map.admin_clear_carts '/admin/carts/clear/:id', :controller => 'admin/carts', :action => 'clear'
  map.admin_ad_preview '/admin/promotions/:id/ad_preview', :controller => 'admin/promotions', :action => 'ad_preview'
  map.admin_user_review_mark_good '/admin/user_reviews/:id/mark_good', :controller => 'admin/user_reviews', :action => 'update', :credit_given => true
  map.admin_user_review_mark_bad  '/admin/user_reviews/:id/mark_bad',  :controller => 'admin/user_reviews', :action => 'update', :credit_given => false
  map.admin_process_void   '/admin/voids/processing/:id',   :controller => 'admin/voids',   :action => 'processing'
  map.admin_process_refund '/admin/refunds/processing/:id', :controller => 'admin/refunds', :action => 'processing'
  map.admin_business_status '/admin/business_payments/status', :controller => 'admin/business_payments', :action => 'status'
  map.connect '/admin/stats/', :controller => 'admin/stats', :action => 'index'
  
  
  map.namespace :admin do |admin|
    admin.resources :admins
    admin.resources :businesses
    admin.resources :carts
    admin.resources :contents
    admin.resources :miscs
    admin.resources :coupons
    admin.resources :credits
    admin.resources :customers
    admin.resources :promotions
    admin.resources :deals
    admin.resources :events
    admin.resources :shoutouts
    admin.resources :origins
    admin.resources :business_payments
    admin.resources :promotion_codes
    admin.resources :purchases
    admin.resources :users
    admin.resources :refunds
    admin.resources :items
    admin.resources :raffles
    admin.resources :user_reviews
    admin.resources :voids
  end

  
  # resources
  map.resources :attendees, :requirements => {:protocol => "http"}
  map.resources :entries, :requirements => {:protocol => "http"}
  map.resources :carts, :requirements => {:protocol => "http"}
  map.resources :cart_items, :requirements => {:protocol => "http"}
  map.resources :coupons, :requirements => {:protocol => "http"}
  map.resources :customers
  map.resources :events, :requirements => {:protocol => "http"}
  map.resources :payment_profiles
  map.resources :promotions, :requirements => {:protocol => "http"}
  map.resources :purchases
  map.resources :users
  map.resource  :user_session
    
  # homepage
  map.root :controller => 'promotions', :action => 'home', :requirements => {:protocol => "http"}
  
  # halfprice dc
  map.about_hpdc '/about_hpdc', :controller => 'static', :action => 'about_hpdc', :requirements => {:protocol => "http"}
  
  # static pages
  map.full_version       'full_version',       :controller => 'static', :action => 'full_version'
  map.mobile_version     'mobile_version',     :controller => 'static', :action => 'mobile_version'
  map.how_it_works       'how_it_works',       :controller => 'static', :action => 'how_it_works', :requirements => {:protocol => "http"}
  map.press              'press',              :controller => 'static', :action => 'press', :requirements => {:protocol => "http"}
  map.referral_info      'referral_info',      :controller => 'static', :action => 'referral_info', :requirements => {:protocol => "http"}
  map.signup             'signup',             :controller => 'static', :action => 'signup', :requirements => {:protocol => "http"}
  map.signup_with_source 'signup/:source',     :controller => 'static', :action => 'signup', :requirements => {:protocol => "http"}
  map.suggest_business   'suggest_business',   :controller => 'static', :action => 'suggest_business', :requirements => {:protocol => "http"}
  map.contact            'contact',            :controller => 'static', :action => 'contact', :requirements => {:protocol => "http"}
  map.about              'about',              :controller => 'static', :action => 'about', :requirements => {:protocol => "http"}
  map.referral_info      'referral_info',      :controller => 'static', :action => 'referral_info', :requirements => {:protocol => "http"}
  map.faq                'faq',                :controller => 'static', :action => 'faq', :requirements => {:protocol => "http"}
  map.terms              'terms',              :controller => 'static', :action => 'terms', :requirements => {:protocol => "http"}
  map.survey             'survey',             :controller => 'static', :action => 'survey', :requirements => {:protocol => "http"}
  map.biz                'biz',                :controller => 'static', :action => 'biz', :requirements => {:protocol => "http"}
  map.mobile_info        'mobile_info',        :controller => 'static', :action => 'mobile_info', :requirements => {:protocol => "http"}
  map.unsubscribe        'unsubscribe',        :controller => 'static', :action => 'unsubscribe', :requirements => {:protocol => "http"}
  map.unsubscribe_thanks 'unsubscribe/thanks', :controller => 'static', :action => 'unsubscribe_thanks', :requirements => {:protocol => "http"}
  map.faq_hpdc           'faq_hpdc',           :controller => 'static', :action => 'faq_hpdc', :requirements => {:protocol => "http"}
  map.contact_hpdc       'contact_hpdc',       :controller => 'static', :action => 'contact_hpdc', :requirements => {:protocol => "http"}
  
  map.connect 'special_event',   :controller => 'static', :action => 'special_event',  :requirements => {:protocol => "http"}
  map.connect 'special_event2',  :controller => 'static', :action => 'special_event2', :requirements => {:protocol => "http"}
  map.connect 'special_event3',  :controller => 'static', :action => 'special_event3', :requirements => {:protocol => "http"}
  map.connect 'special_event4',  :controller => 'static', :action => 'special_event4', :requirements => {:protocol => "http"}
  map.connect 'special_event5',  :controller => 'static', :action => 'special_event5', :requirements => {:protocol => "http"}
  map.connect 'signup2',         :controller => 'static', :action => 'signup2',        :requirements => {:protocol => "http"}
  map.connect 'signup3',         :controller => 'static', :action => 'signup3',        :requirements => {:protocol => "http"}
  map.connect 'signup4',         :controller => 'static', :action => 'signup4',        :requirements => {:protocol => "http"}
  map.connect 'happyhour',       :controller => 'static', :action => 'happyhour',      :requirements => {:protocol => "http"}
  map.connect 'happyhour2',      :controller => 'static', :action => 'happyhour2',     :requirements => {:protocol => "http"}
  map.connect 'marchmadness',    :controller => 'static', :action => 'marchmadness',   :requirements => {:protocol => "http"}
  map.connect 'rsvp_thanks',     :controller => 'static', :action => 'rsvp_thanks',    :requirements => {:protocol => "http"}
  map.connect 'rap',             :controller => 'static', :action => 'rap',            :requirements => {:protocol => "http"}
  map.connect 'rap_tour',        :controller => 'static', :action => 'rap_tour',       :requirements => {:protocol => "http"}
  map.connect 'nationals_deal',  :controller => 'static', :action => 'nationals_deal'
  map.connect 'ontap',           :controller => 'static', :action => 'signup', :source => 'ontap', :utm_source => 'ontap', :utm_medium => 'magazine', :utm_campaign => 'ontap_mag_ad_feb2011'
  map.connect 'totn',            :controller => 'static', :action => 'signup', :source => 'totn',  :utm_source => 'totn',  :utm_medium => 'magazine', :utm_campaign => 'totn_ad'
  map.connect 'pitc',            :controller => 'static', :action => 'signup', :source => 'pitc',  :utm_source => 'pitc'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
