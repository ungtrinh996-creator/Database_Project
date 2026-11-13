 ### 1. Thông tin chung về Phase 3                   
                                                      
  • Nội dung chính: Normalization (Chuẩn hóa CSDL) &  
  Physical Database Design / Data Implementation (Cài 
  đặt CSDL vật lý).                                   
  • Trọng số điểm: 10% (Điểm nhóm).                   
  • Hạn nộp (Due date): 23h59' ngày 14/11/2026.       
  • Hình thức nộp: 01 file duy nhất (PDF hoặc MS Word),
  viết hoàn toàn bằng tiếng Anh, gửi qua email giảng  
  viên: hoand@ptit.edu.vn.                            
  • Tiêu đề email chuẩn: [E24-Class 5] group 5 –      
  report phase 3 (Nhóm 5).                            
  ──────                                              
  ### 2. Hai nhiệm vụ cốt lõi cần làm trong Phase 3   
                                                      
  #### Nhiệm vụ 1: Normalization (Chuẩn hóa CSDL)     
                                                      
  Dựa trên tập lược đồ quan hệ (Relational Schemas) đã
  ánh xạ từ ERD ở Phase 2:                            
                                                      
  1. Xác định các phụ thuộc hàm (Functional           
  Dependencies - FDs):                                
      • Liệt kê đầy đủ tất cả các FD có ý nghĩa nghiệp
      vụ cho từng quan hệ/bảng (ví dụ: A → B).        
  2. Xác định các khóa ứng viên (Candidate Keys):     
      • Tìm tất cả khóa ứng viên cho từng bảng dựa    
      trên tập phụ thuộc hàm và bao đóng thuộc tính.  
  3. Chuẩn hóa về Dạng chuẩn 3 (3rd Normal Form -     
  3NF):                                               
      • Kiểm tra và phân tích từng bảng qua các dạng  
      chuẩn: 1NF → 2NF → 3NF (chỉ ra các vi phạm nếu  
      có như phụ thuộc từng phần Partial Dependency   
      hoặc phụ thuộc bắc cầu Transitive Dependency).  
      • Tiến hành tách bảng (Lossless Join            
      Decomposition & Dependency Preserving) nếu bảng 
      chưa đạt 3NF.                                   
      • Trình bày danh sách lược đồ quan hệ hoàn chỉnh
      sau khi đã đạt chuẩn 3NF (rõ Primary Key,       
      Foreign Key).                                   
                                                      
  ──────                                              
  #### Nhiệm vụ 2: Physical Database Design &         
  Implementation (Cài đặt CSDL thực tế)               
                                                      
  Triển khai hệ thống CSDL trên một hệ quản trị CSDL  
  thực tế (chọn một trong các DBMS như PostgreSQL,    
  MySQL, SQL Server, hoặc Oracle):                    
                                                      
  1. Viết Script DDL (Data Definition Language):      
      • Tạo cơ sở dữ liệu (CREATE DATABASE).          
      • Tạo các bảng theo lược đồ đã chuẩn hóa 3NF    
      (CREATE TABLE).                                 
      • Khai báo đầy đủ các ràng buộc: PRIMARY KEY,   
      FOREIGN KEY (với ON DELETE / ON UPDATE phù hợp),
      UNIQUE, NOT NULL, CHECK constraints, và DEFAULT.
      • Cài đặt các Trigger / Stored Procedure cho các
      ràng buộc nghiệp vụ phức tạp (như 8 ràng buộc   
      không thể biểu diễn trên ERD mà nhóm đã chỉ ra ở
      cuối Phase 2).                                  
  2. Tạo dữ liệu mẫu (Data Population / DML):         
      • Thêm dữ liệu mẫu vào tất cả các bảng bằng câu 
      lệnh INSERT (hoặc file .sql nạp dữ liệu).       
      • Yêu cầu bắt buộc: Dữ liệu phải đầy đủ và có ý 
      nghĩa nghiệp vụ (sufficient amount of realistic 
      data) để khi chạy truy vấn cho ra kết quả trực  
      quan, thuyết phục, không để bảng trống hoặc chỉ 
      có 1–2 dòng sơ sài.                             
  3. Cài đặt các câu truy vấn nghiệp vụ (SQL Queries &
  Applications):                                      
      • Viết các câu lệnh SQL đáp ứng các bài toán và 
      nghiệp vụ đã nêu ở Phase 2 (Phần 4: Database    
      Applications: loads, updates, queries, reports..
      .):                                             
          • Truy vấn kết nối nhiều bảng (Multi-table  
          JOIN).                                      
          • Truy vấn thống kê, tổng hợp dữ liệu (GROUP
          BY, HAVING, SUM, AVG, COUNT).               
          • Truy vấn lồng (Nested subqueries), Common 
          Table Expressions (WITH).                   
          • Báo cáo chi phí dự án, tiến độ công việc, 
          vật tư tồn kho, thiết bị, chấm công, an toàn
          lao động...                                 
                                                      
                                                      
  ──────                                              
  ### 3. Cấu trúc nội dung cần có trong Báo cáo nộp   
  (Report Phase 3)                                    
                                                      
  Báo cáo Phase 3 cần bao gồm các phần chính sau:     
                                                      
  1. Introduction & Final Relational Schema: Tóm tắt  
  ngắn gọn mô hình từ Phase 2.                        
  2. Functional Dependencies & Normalization:         
      • Bảng kê FDs và Candidate Keys của từng quan hệ.
      • Phân tích chứng minh các bảng đã đạt chuẩn 3NF
      (hoặc quá trình tách bảng từ chưa chuẩn sang    
      3NF).                                           
      • Lược đồ quan hệ hoàn chỉnh cuối cùng ở dạng   
      3NF.                                            
  3. Database Implementation Details:                 
      • Hệ quản trị CSDL được lựa chọn và lý do chọn. 
      • Mã nguồn DDL (Data Definition Language) có chú
      thích rõ ràng.                                  
  4. Proofs of Implementation (Bằng chứng triển khai):
      • Ảnh chụp màn hình giao diện DBMS (hoặc        
      terminal) chứng minh đã tạo bảng thành công.    
      • Ảnh chụp bảng dữ liệu mẫu sau khi đã insert   
      thành công (SELECT * hoặc Data Viewer).         
      • Danh sách các câu truy vấn mẫu                
      (Queries/Reports) kèm ảnh chụp kết quả thực thi 
      trên DBMS để chứng minh hệ thống hoạt động đúng.
                                                      
  ──────                                              
  ### Gợi ý bước đi tiếp theo:                        
                                                      
  Nếu bạn muốn, chúng ta có thể bắt đầu ngay với:     
                                                      
  1. Viết danh sách Functional Dependencies (FDs) và  
  xác định Candidate Keys cho toàn bộ 17+ bảng trong  
  hệ thống quản lý công ty xây dựng A34Build của nhóm.
  2. Soạn thảo file script SQL DDL & DML cho hệ quản  
  trị CSDL mà nhóm bạn dự định sử dụng (MySQL /       
  PostgreSQL / SQL Server).     