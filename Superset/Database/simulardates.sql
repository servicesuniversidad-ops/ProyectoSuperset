


-- Crea Primeramente la particion Si no existe

-- CREATE TABLE IF NOT EXISTS measurements_y2026_m06 
-- PARTITION OF measurements
-- FOR VALUES FROM ('2026-06-01 00:00:00-05') TO ('2026-05-31 00:00:00-05');


-- ============================================
-- SIMULACIÓN DE DATOS - TIENDA OLÍMPICA
-- Mes: Marzo 2026
-- 7 Dispositivos con patrones realistas
-- DEV-001 (GENERAL) mide la suma real en el breaker principal
-- ============================================

DO $$
DECLARE
    v_timestamp TIMESTAMPTZ := '2026-05-19 00:00:00-05'; -- Inicio marzo 2026
    v_end_timestamp TIMESTAMPTZ := '2026-05-31 00:00:00-05'; -- Fin marzo 2026
    v_device_id VARCHAR(50);
    v_hour INT;
    v_dow INT; -- 0=Domingo, 6=Sábado
    v_minute INT;
    
    -- Variables de carga
    v_base_current DECIMAL;
    v_multiplier DECIMAL;
    v_weekend_factor DECIMAL;
    v_peak_hour_factor DECIMAL;
    
    -- Variables eléctricas
    v_voltage_l1 DECIMAL;
    v_voltage_l2 DECIMAL;
    v_voltage_l3 DECIMAL;
    v_current_l1 DECIMAL;
    v_current_l2 DECIMAL;
    v_current_l3 DECIMAL;
    v_power_factor DECIMAL;
    v_thd DECIMAL;
    v_power_active DECIMAL;
    v_power_reactive DECIMAL;
    v_power_apparent DECIMAL;
    
    -- Acumuladores para GENERAL (DEV-001)
    v_total_power_active DECIMAL;
    v_total_power_reactive DECIMAL;
    v_total_power_apparent DECIMAL;
    v_weighted_pf DECIMAL;
    v_avg_thd DECIMAL;
    
    -- Variables para GENERAL
    v_gen_voltage_l1 DECIMAL;
    v_gen_voltage_l2 DECIMAL;
    v_gen_voltage_l3 DECIMAL;
    v_gen_current_l1 DECIMAL;
    v_gen_current_l2 DECIMAL;
    v_gen_current_l3 DECIMAL;
    v_system_losses DECIMAL;
    
    -- Array de dispositivos (excepto GENERAL)
    v_devices VARCHAR[] := ARRAY['DEV-002', 'DEV-003', 'DEV-004', 'DEV-005', 'DEV-006', 'DEV-007'];
    
    -- Contador de THD ponderado
    v_thd_sum DECIMAL;
    v_power_sum DECIMAL;
    
BEGIN
    RAISE NOTICE 'Iniciando simulación para Marzo 2026 - Tienda Olímpica';
    
    WHILE v_timestamp < v_end_timestamp LOOP
        v_hour := EXTRACT(HOUR FROM v_timestamp);
        v_dow := EXTRACT(DOW FROM v_timestamp);
        v_minute := EXTRACT(MINUTE FROM v_timestamp);
        
        -- Factor de fin de semana (viernes tarde, sábado y domingo más concurrido)
        v_weekend_factor := CASE 
            WHEN v_dow = 0 THEN 1.25  -- Domingo
            WHEN v_dow = 6 THEN 1.30  -- Sábado (día más concurrido)
            WHEN v_dow = 5 AND v_hour >= 17 THEN 1.20  -- Viernes tarde
            ELSE 1.0 
        END;
        
        -- Factor de horas pico (9am-12pm y 5pm-8pm)
        v_peak_hour_factor := CASE 
            WHEN v_hour BETWEEN 9 AND 11 THEN 1.15  -- Pico mañana
            WHEN v_hour BETWEEN 17 AND 19 THEN 1.25  -- Pico tarde (mayor)
            WHEN v_hour BETWEEN 12 AND 16 THEN 0.85  -- Valle tarde
            WHEN v_hour BETWEEN 20 AND 21 THEN 0.90  -- Cierre
            ELSE 0.60  -- Madrugada/cierre
        END;
        
        -- Inicializar acumuladores para GENERAL
        v_total_power_active := 0;
        v_total_power_reactive := 0;
        v_total_power_apparent := 0;
        v_thd_sum := 0;
        v_power_sum := 0;
        
        -- ==========================================
        -- PROCESAR CADA DISPOSITIVO (DEV-002 a DEV-007)
        -- ==========================================
        FOREACH v_device_id IN ARRAY v_devices LOOP
            
            -- Voltajes base con pequeñas variaciones
            v_voltage_l1 := 120.0 + (random() * 4 - 2); -- 118-122V
            v_voltage_l2 := 120.0 + (random() * 4 - 2);
            v_voltage_l3 := 120.0 + (random() * 4 - 2);
            
            CASE v_device_id
                -- ==========================================
                -- DEV-002: ÁREA DE FRÍO (45% del consumo)
                -- Cuartos fríos, neveras, congeladores
                -- Carga constante 24/7 con ligeras variaciones
                -- ==========================================
                WHEN 'DEV-002' THEN
                    -- Corriente base alta ~200A (para ~67.5 kW)
                    v_base_current := 195 + random() * 15;
                    
                    -- Muy poca variación, solo por ciclos de compresor
                    v_multiplier := 1.0 + (random() * 0.10 - 0.05); -- ±5%
                    
                    -- Ligero aumento cuando se abre la tienda (más apertura de puertas)
                    IF v_hour BETWEEN 7 AND 22 THEN
                        v_multiplier := v_multiplier * 1.08;
                    END IF;
                    
                    -- Factor de potencia típico de motores
                    v_power_factor := 0.85 + random() * 0.05;
                    v_thd := 2.5 + random() * 1.5; -- THD moderado
                
                -- ==========================================
                -- DEV-003: CONFORT TÉRMICO (23% del consumo)
                -- Aires acondicionados
                -- Varía según hora del día (temperatura)
                -- ==========================================
                WHEN 'DEV-003' THEN
                    -- Corriente base ~85A (para ~34.5 kW)
                    v_base_current := 80 + random() * 10;
                    
                    -- Variación por temperatura del día
                    v_multiplier := CASE
                        WHEN v_hour BETWEEN 0 AND 6 THEN 0.30      -- Noche, apagado/mínimo
                        WHEN v_hour BETWEEN 7 AND 9 THEN 0.60      -- Encendiendo
                        WHEN v_hour BETWEEN 10 AND 15 THEN 1.20    -- Máximo calor del día
                        WHEN v_hour BETWEEN 16 AND 19 THEN 1.00    -- Tarde calurosa
                        WHEN v_hour BETWEEN 20 AND 21 THEN 0.70    -- Enfriando
                        ELSE 0.20                                   -- Cerrado
                    END;
                    
                    -- Más A/C cuando hay más gente
                    v_multiplier := v_multiplier * v_weekend_factor * (0.9 + v_peak_hour_factor * 0.1);
                    
                    v_power_factor := 0.88 + random() * 0.06;
                    v_thd := 3.0 + random() * 2.0; -- THD más alto (variadores)
                
                -- ==========================================
                -- DEV-004: PANADERÍA Y COMIDAS (5% del consumo)
                -- Hornos, freidoras, estufas
                -- Picos en madrugada (horneado) y medio día (comidas)
                -- ==========================================
                WHEN 'DEV-004' THEN
                    -- Corriente base ~19A (para ~7.5 kW)
                    v_base_current := 18 + random() * 3;
                    
                    v_multiplier := CASE
                        WHEN v_hour BETWEEN 3 AND 6 THEN 3.50      -- Horneado madrugada (PICO)
                        WHEN v_hour BETWEEN 7 AND 9 THEN 2.80      -- Producción mañana
                        WHEN v_hour BETWEEN 10 AND 14 THEN 2.50    -- Comidas calientes
                        WHEN v_hour BETWEEN 15 AND 18 THEN 1.80    -- Tarde
                        WHEN v_hour BETWEEN 19 AND 21 THEN 1.20    -- Últimas preparaciones
                        ELSE 0.15                                   -- Standby
                    END;
                    
                    -- Fines de semana más producción
                    IF v_dow IN (0, 6) THEN
                        v_multiplier := v_multiplier * 1.20;
                    END IF;
                    
                    v_power_factor := 0.96 + random() * 0.03; -- Cargas resistivas (hornos)
                    v_thd := 4.5 + random() * 3.5; -- THD alto (elementos eléctricos)
                
                -- ==========================================
                -- DEV-005: CARNICERÍA Y PESCADERÍA (8% del consumo)
                -- Sierras, molinos, cámaras, vitrinas refrigeradas
                -- ==========================================
                WHEN 'DEV-005' THEN
                    -- Corriente base ~30A (para ~12 kW)
                    v_base_current := 28 + random() * 5;
                    
                    v_multiplier := CASE
                        WHEN v_hour BETWEEN 5 AND 7 THEN 2.50      -- Preparación temprana
                        WHEN v_hour BETWEEN 8 AND 12 THEN 2.00     -- Pico mañana
                        WHEN v_hour BETWEEN 13 AND 18 THEN 1.50    -- Tarde normal
                        WHEN v_hour BETWEEN 19 AND 21 THEN 1.00    -- Limpieza
                        ELSE 0.40                                   -- Solo refrigeración
                    END;
                    
                    v_multiplier := v_multiplier * v_weekend_factor;
                    
                    v_power_factor := 0.87 + random() * 0.05; -- Motores
                    v_thd := 2.8 + random() * 2.0;
                
                -- ==========================================
                -- DEV-006: ILUMINACIÓN (15% del consumo)
                -- LED + algunas fluorescentes
                -- Encendido durante horario comercial
                -- ==========================================
                WHEN 'DEV-006' THEN
                    -- Corriente base ~55A (para ~22.5 kW)
                    v_base_current := 52 + random() * 6;
                    
                    v_multiplier := CASE
                        WHEN v_hour BETWEEN 6 AND 7 THEN 0.60      -- Encendido parcial
                        WHEN v_hour BETWEEN 8 AND 21 THEN 1.00     -- 100% encendido
                        WHEN v_hour BETWEEN 22 AND 23 THEN 0.30    -- Luces de seguridad
                        ELSE 0.10                                   -- Mínimo nocturno
                    END;
                    
                    -- Pequeñas variaciones por sensores/áreas
                    v_multiplier := v_multiplier * (0.95 + random() * 0.10);
                    
                    v_power_factor := 0.95 + random() * 0.04; -- LED buen FP
                    v_thd := 1.5 + random() * 1.0; -- THD bajo
                
                -- ==========================================
                -- DEV-007: PUNTOS DE VENTA (4% del consumo)
                -- Cajas registradoras, lectores, computadores
                -- Activo en horario comercial
                -- ==========================================
                WHEN 'DEV-007' THEN
                    -- Corriente base ~15A (para ~6 kW)
                    v_base_current := 14 + random() * 2;
                    
                    v_multiplier := CASE
                        WHEN v_hour BETWEEN 7 AND 8 THEN 0.80      -- Encendiendo sistemas
                        WHEN v_hour BETWEEN 9 AND 21 THEN 1.00     -- Operación normal
                        WHEN v_hour BETWEEN 22 AND 23 THEN 0.40    -- Cerrando
                        ELSE 0.05                                   -- Standby
                    END;
                    
                    -- Más cajas activas en horas pico y fines de semana
                    v_multiplier := v_multiplier * (v_peak_hour_factor * 0.3 + 0.7) * v_weekend_factor;
                    
                    v_power_factor := 0.97 + random() * 0.02; -- Equipos electrónicos
                    v_thd := 1.8 + random() * 1.2;
                
            END CASE;
            
            -- Aplicar multiplicador final a la corriente
            v_current_l1 := v_base_current * v_multiplier;
            v_current_l2 := v_current_l1 * (0.98 + random() * 0.04); -- Desbalance ligero
            v_current_l3 := v_current_l1 * (0.98 + random() * 0.04);
            
            -- Cálculos de potencia (sistema trifásico)
            v_power_apparent := (v_voltage_l1 * v_current_l1 + 
                                v_voltage_l2 * v_current_l2 + 
                                v_voltage_l3 * v_current_l3) / 1000; -- kVA
            
            v_power_active := v_power_apparent * v_power_factor; -- kW
            
            v_power_reactive := v_power_apparent * SQRT(ABS(1 - POWER(v_power_factor, 2))); -- kVAr
            
            -- Acumular para el sensor GENERAL
            v_total_power_active := v_total_power_active + v_power_active;
            v_total_power_reactive := v_total_power_reactive + v_power_reactive;
            v_total_power_apparent := v_total_power_apparent + v_power_apparent;
            
            -- Acumular THD ponderado por potencia
            v_thd_sum := v_thd_sum + (v_thd * v_power_active);
            v_power_sum := v_power_sum + v_power_active;
            
            -- Insertar medición del dispositivo
            INSERT INTO measurements (
                device_id, timestamp,
                voltage_l1, voltage_l2, voltage_l3,
                current_l1, current_l2, current_l3,
                power_active, power_reactive, power_apparent,
                thd_voltage_l1, thd_voltage_l2, thd_voltage_l3,
                power_factor
            ) VALUES (
                v_device_id, v_timestamp,
                v_voltage_l1, v_voltage_l2, v_voltage_l3,
                v_current_l1, v_current_l2, v_current_l3,
                v_power_active, v_power_reactive, v_power_apparent,
                v_thd, v_thd * (0.98 + random() * 0.04), v_thd * (0.98 + random() * 0.04),
                v_power_factor
            );
            
        END LOOP; -- Fin loop dispositivos
        
        -- ==========================================
        -- DEV-001: GENERAL (BREAKER PRINCIPAL)
        -- Sensor que mide la suma de todos los circuitos
        -- Con pérdidas del sistema y sus propias mediciones
        -- ==========================================
        
        -- El sensor del breaker principal tiene sus propias lecturas de voltaje
        -- Puede ser ligeramente diferente a los sensores individuales
        v_gen_voltage_l1 := 120.0 + (random() * 4 - 2);
        v_gen_voltage_l2 := 120.0 + (random() * 4 - 2);
        v_gen_voltage_l3 := 120.0 + (random() * 4 - 2);
        
        -- Pérdidas del sistema (cables, conexiones, etc.) ~1-2%
        v_system_losses := 1.01 + (random() * 0.01); -- 1-2% de pérdidas
        
        -- Aplicar pérdidas a las potencias totales
        v_total_power_active := v_total_power_active * v_system_losses;
        v_total_power_reactive := v_total_power_reactive * v_system_losses;
        v_total_power_apparent := v_total_power_apparent * v_system_losses;
        
        -- Factor de potencia del sistema (basado en potencias totales)
        v_weighted_pf := CASE 
            WHEN v_total_power_apparent > 0 THEN 
                LEAST(v_total_power_active / v_total_power_apparent, 0.99)
            ELSE 0.90
        END;
        
        -- THD promedio ponderado del sistema
        v_avg_thd := CASE
            WHEN v_power_sum > 0 THEN v_thd_sum / v_power_sum
            ELSE 2.5
        END;
        
        -- Calcular corrientes en el breaker principal basadas en la potencia total
        -- I = P / (√3 × V × PF) para sistemas trifásicos
        -- Simplificado: I_total = S / (V_promedio × 3) para cada fase
        
        v_gen_current_l1 := (v_total_power_apparent * 1000) / 
                           ((v_gen_voltage_l1 + v_gen_voltage_l2 + v_gen_voltage_l3) / 3) / 3;
        
        -- Desbalance natural de cargas (3-5% entre fases)
        v_gen_current_l2 := v_gen_current_l1 * (0.97 + random() * 0.06);
        v_gen_current_l3 := v_gen_current_l1 * (0.97 + random() * 0.06);
        
        -- Pequeño error de medición del sensor (±0.5%)
        v_gen_current_l1 := v_gen_current_l1 * (0.995 + random() * 0.01);
        v_gen_current_l2 := v_gen_current_l2 * (0.995 + random() * 0.01);
        v_gen_current_l3 := v_gen_current_l3 * (0.995 + random() * 0.01);
        
        -- Recalcular potencia aparente con las corrientes y voltajes del sensor general
        v_total_power_apparent := (v_gen_voltage_l1 * v_gen_current_l1 + 
                                   v_gen_voltage_l2 * v_gen_current_l2 + 
                                   v_gen_voltage_l3 * v_gen_current_l3) / 1000;
        
        -- Ajustar potencia activa con el FP calculado
        v_total_power_active := v_total_power_apparent * v_weighted_pf;
        
        -- Recalcular potencia reactiva
        v_total_power_reactive := v_total_power_apparent * SQRT(ABS(1 - POWER(v_weighted_pf, 2)));
        
        INSERT INTO measurements (
            device_id, timestamp,
            voltage_l1, voltage_l2, voltage_l3,
            current_l1, current_l2, current_l3,
            power_active, power_reactive, power_apparent,
            thd_voltage_l1, thd_voltage_l2, thd_voltage_l3,
            power_factor
        ) VALUES (
            'DEV-001', v_timestamp,
            v_gen_voltage_l1, v_gen_voltage_l2, v_gen_voltage_l3,
            v_gen_current_l1, v_gen_current_l2, v_gen_current_l3,
            v_total_power_active, v_total_power_reactive, v_total_power_apparent,
            v_avg_thd, v_avg_thd * (0.98 + random() * 0.04), v_avg_thd * (0.98 + random() * 0.04),
            v_weighted_pf
        );
        
        -- Avanzar 5 minutos
        v_timestamp := v_timestamp + INTERVAL '5 minutes';
        
        -- Progreso cada día
        IF EXTRACT(HOUR FROM v_timestamp) = 0 AND EXTRACT(MINUTE FROM v_timestamp) = 0 THEN
            RAISE NOTICE 'Procesado: %', v_timestamp::DATE;
        END IF;
        
    END LOOP;
    
    RAISE NOTICE 'Simulación completada. Total registros insertados: %', 
                 (SELECT COUNT(*) FROM measurements WHERE timestamp >= '2026-03-01' AND timestamp < '2026-04-01');
    
END $$;

-- ==========================================
-- VERIFICACIÓN DE DATOS
-- ==========================================

-- Ver distribución de consumo por dispositivo
SELECT 
    d.device_id,
    CASE d.device_id
        WHEN 'DEV-001' THEN 'GENERAL (Breaker Principal) ⚡'
        WHEN 'DEV-002' THEN 'Área de Frío ❄️'
        WHEN 'DEV-003' THEN 'Confort Térmico (A/C) 🌡️'
        WHEN 'DEV-004' THEN 'Panadería y Comidas 🍞'
        WHEN 'DEV-005' THEN 'Carnicería y Pescadería 🥩'
        WHEN 'DEV-006' THEN 'Iluminación 💡'
        WHEN 'DEV-007' THEN 'Puntos de Venta 🛒'
    END as area,
    ROUND(AVG(m.power_active), 2) as potencia_promedio_kw,
    ROUND(MAX(m.power_active), 2) as potencia_maxima_kw,
    ROUND(MIN(m.power_active), 2) as potencia_minima_kw,
    ROUND(SUM(m.power_active * 5.0/60.0), 2) as consumo_total_kwh, -- 5 minutos
    ROUND(AVG(m.power_factor), 3) as fp_promedio,
    ROUND(AVG(m.current_l1), 2) as corriente_promedio_a,
    COUNT(*) as num_mediciones
FROM measurements m
JOIN devices d ON m.device_id = d.device_id
WHERE m.timestamp >= '2026-03-01' AND m.timestamp < '2026-04-01'
GROUP BY d.device_id
ORDER BY d.device_id;

-- Ver porcentaje de consumo (excluyendo GENERAL)
WITH consumo_areas AS (
    SELECT 
        device_id,
        SUM(power_active) as total_consumo
    FROM measurements
    WHERE timestamp >= '2026-03-01' 
      AND timestamp < '2026-04-01'
      AND device_id != 'DEV-001'
    GROUP BY device_id
)
SELECT 
    device_id,
    CASE device_id
        WHEN 'DEV-002' THEN 'Área de Frío (objetivo: 45%)'
        WHEN 'DEV-003' THEN 'Confort Térmico (objetivo: 23%)'
        WHEN 'DEV-004' THEN 'Panadería y Comidas (objetivo: 5%)'
        WHEN 'DEV-005' THEN 'Carnicería y Pescadería (objetivo: 8%)'
        WHEN 'DEV-006' THEN 'Iluminación (objetivo: 15%)'
        WHEN 'DEV-007' THEN 'Puntos de Venta (objetivo: 4%)'
    END as area,
    ROUND(100.0 * total_consumo / SUM(total_consumo) OVER (), 2) as porcentaje_real
FROM consumo_areas
ORDER BY device_id;

-- Comparar GENERAL vs suma de circuitos derivados
WITH general_data AS (
    SELECT 
        SUM(power_active * 5.0/60.0) as consumo_general_kwh,
        AVG(power_active) as potencia_promedio_general
    FROM measurements
    WHERE device_id = 'DEV-001'
      AND timestamp >= '2026-03-01' 
      AND timestamp < '2026-04-01'
),
circuitos_data AS (
    SELECT 
        SUM(power_active * 5.0/60.0) as consumo_circuitos_kwh,
        AVG(power_active) as potencia_promedio_circuitos
    FROM measurements
    WHERE device_id IN ('DEV-002', 'DEV-003', 'DEV-004', 'DEV-005', 'DEV-006', 'DEV-007')
      AND timestamp >= '2026-03-01' 
      AND timestamp < '2026-04-01'
)
SELECT 
    ROUND(g.consumo_general_kwh, 2) as consumo_general_kwh,
    ROUND(c.consumo_circuitos_kwh, 2) as consumo_circuitos_kwh,
    ROUND(g.consumo_general_kwh - c.consumo_circuitos_kwh, 2) as diferencia_kwh,
    ROUND(100.0 * (g.consumo_general_kwh - c.consumo_circuitos_kwh) / c.consumo_circuitos_kwh, 2) as porcentaje_perdidas,
    ROUND(g.potencia_promedio_general, 2) as potencia_prom_general_kw,
    ROUND(c.potencia_promedio_circuitos, 2) as potencia_prom_circuitos_kw
FROM general_data g, circuitos_data c;

-- Patrón de consumo por hora del día (DEV-001)
SELECT 
    EXTRACT(HOUR FROM timestamp) as hora,
    ROUND(AVG(power_active), 2) as potencia_promedio_kw,
    ROUND(AVG(power_factor), 3) as fp_promedio,
    ROUND(AVG(current_l1), 2) as corriente_l1_promedio_a
FROM measurements
WHERE device_id = 'DEV-001'
  AND timestamp >= '2026-03-01' 
  AND timestamp < '2026-04-01'
GROUP BY EXTRACT(HOUR FROM timestamp)
ORDER BY hora;

-- Verificar coherencia: comparar un timestamp específico
SELECT 
    timestamp,
    device_id,
    ROUND(power_active, 2) as potencia_kw,
    ROUND(current_l1, 2) as corriente_a,
    ROUND(power_factor, 3) as fp
FROM measurements
WHERE timestamp = '2026-03-15 12:00:00-05'
ORDER BY device_id;
