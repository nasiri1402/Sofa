//
//  Project.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import SwiftUI

struct Project: Identifiable {
    let id: UUID
    let brief: Brief
    let summary: String
    var plans: [Plan]
    var hasLifetimeAccess: Bool
    let createdAt: Date
    var updatedAt: Date
    var isCompleted: Bool {
        plans.allSatisfy(\.isCompleted)
    }
}

extension Project {

    // MARK: - Brief

    struct Brief: Identifiable, Hashable {
        let id: UUID
        let category: Category
        let focus: String
        let target: String
        let currentState: String
        let preferences: String
        let timeframe: Timeframe

        func copy(id: UUID) -> Brief {
            Brief(
                id: id,
                category: category,
                focus: focus,
                target: target,
                currentState: currentState,
                preferences: preferences,
                timeframe: timeframe
            )
        }
    }

    // MARK: - Plan

    struct Plan: Identifiable, Hashable {
        let id: UUID
        let title: String
        let emoji: String
        let firstResults: String
        let budget: Int
        let result: String
        let difficulty: Difficulty
        var weeks: [Week]
        var chat: Chat?
        var isFavorite: Bool
        let createdAt: Date
        var allSteps: [Step] {
            weeks.flatMap(\.steps)
        }
        var progress: Double {
            guard !allSteps.isEmpty else { return .zero }
            let completedSteps = allSteps.filter(\.isCompleted)
            let ratio = Double(completedSteps.count) / Double(allSteps.count)
            return max(0, min(1, ratio))
        }
        var isCompleted: Bool {
            weeks.allSatisfy(\.isCompleted)
        }

        func copy(id: UUID) -> Plan {
            Project.Plan(
                id: id,
                title: title,
                emoji: emoji,
                firstResults: firstResults,
                budget: budget,
                result: result,
                difficulty: difficulty,
                weeks: weeks,
                chat: chat,
                isFavorite: isFavorite,
                createdAt: createdAt
            )
        }
    }
}

extension Project.Brief {

    // MARK: - Category

    enum Category: String, CaseIterable, Hashable {
        case money
        case content
        case business
        case learning
        case health
        case creativity
        case career
        case itProduct = "it_product"
        case productivity

        var title: String {
            switch self {
            case .money: BriefLocalization.text(en: "Money", ru: "Деньги")
            case .content: BriefLocalization.text(en: "Content", ru: "Контент")
            case .business: BriefLocalization.text(en: "Business", ru: "Бизнес")
            case .learning: BriefLocalization.text(en: "Learning", ru: "Обучение")
            case .health: BriefLocalization.text(en: "Health", ru: "Здоровье")
            case .creativity: BriefLocalization.text(en: "Creativity", ru: "Творчество")
            case .career: BriefLocalization.text(en: "Career", ru: "Карьера")
            case .itProduct: BriefLocalization.text(en: "IT & product", ru: "IT и продукт")
            case .productivity: BriefLocalization.text(en: "Productivity", ru: "Продуктивность")
            }
        }

        var subtitle: String {
            switch self {
            case .money:
                BriefLocalization.text(
                    en: "Income, savings, debt, investing",
                    ru: "Доход, сбережения, долги, инвестиции")
            case .content:
                BriefLocalization.text(
                    en: "Reels, YouTube, TikTok, Telegram", ru: "Reels, YouTube, TikTok, Telegram")
            case .business:
                BriefLocalization.text(
                    en: "Clients, sales, launch, marketplaces",
                    ru: "Клиенты, продажи, запуск, маркетплейсы")
            case .learning:
                BriefLocalization.text(
                    en: "Languages, exams, career skills", ru: "Языки, экзамены, карьерные навыки")
            case .health:
                BriefLocalization.text(
                    en: "Training, nutrition, sleep, energy",
                    ru: "Тренировки, питание, сон, энергия")
            case .creativity:
                BriefLocalization.text(
                    en: "Music, photo, video, design, art",
                    ru: "Музыка, фото, видео, дизайн, искусство")
            case .career:
                BriefLocalization.text(
                    en: "Jobs, freelance, promotion, salary",
                    ru: "Работа, фриланс, повышение, доход")
            case .itProduct:
                BriefLocalization.text(
                    en: "Programming, AI, product, design",
                    ru: "Программирование, AI, продукт, дизайн")
            case .productivity:
                BriefLocalization.text(
                    en: "Discipline, focus, routine, habits",
                    ru: "Дисциплина, фокус, рутина, привычки")
            }
        }

        var focusQuestion: String {
            switch self {
            case .money:
                BriefLocalization.text(
                    en: "What financial result do you need?",
                    ru: "Какой финансовый результат тебе нужен?")
            case .content:
                BriefLocalization.text(
                    en: "Where do you want to grow?", ru: "Где ты хочешь вырасти?")
            case .business:
                BriefLocalization.text(
                    en: "What does your business need?", ru: "Что нужно твоему бизнесу?")
            case .learning:
                BriefLocalization.text(
                    en: "What do you want to learn?", ru: "Чему ты хочешь научиться?")
            case .health:
                BriefLocalization.text(en: "What is the main goal?", ru: "Какая главная цель?")
            case .creativity:
                BriefLocalization.text(
                    en: "Where do you want to grow?", ru: "Где ты хочешь вырасти?")
            case .career:
                BriefLocalization.text(
                    en: "What do you need for work?", ru: "Что тебе нужно для работы?")
            case .itProduct:
                BriefLocalization.text(
                    en: "Which IT track fits best?", ru: "Какое IT-направление подходит лучше?")
            case .productivity:
                BriefLocalization.text(
                    en: "What do you want to improve?", ru: "Что ты хочешь улучшить?")
            }
        }

        var focusOptions: [String] {
            switch self {
            case .money:
                [
                    BriefLocalization.text(en: "Pay off debt", ru: "Закрыть долг"),
                    BriefLocalization.text(en: "Increase income", ru: "Увеличить доход"),
                    BriefLocalization.text(en: "Save for a purchase", ru: "Накопить на покупку"),
                    BriefLocalization.text(en: "Start investing", ru: "Начать инвестировать"),
                ]
            case .content:
                ["Instagram / Reels", "YouTube", "TikTok", "Telegram"]
            case .business:
                [
                    BriefLocalization.text(en: "Clients and leads", ru: "Клиенты и лиды"),
                    BriefLocalization.text(en: "More sales", ru: "Больше продаж"),
                    BriefLocalization.text(en: "Launch from zero", ru: "Запуск с нуля"),
                    BriefLocalization.text(en: "Marketplaces", ru: "Маркетплейсы"),
                ]
            case .learning:
                [
                    BriefLocalization.text(en: "English", ru: "Английский"),
                    BriefLocalization.text(en: "IT / career skill", ru: "IT / карьерный навык"),
                    BriefLocalization.text(en: "Soft skills", ru: "Soft skills"),
                    BriefLocalization.text(en: "Exams and study", ru: "Экзамены и учеба"),
                ]
            case .health:
                [
                    BriefLocalization.text(en: "Lose weight", ru: "Похудеть"),
                    BriefLocalization.text(en: "Gym and training", ru: "Зал и тренировки"),
                    BriefLocalization.text(en: "Nutrition", ru: "Питание"),
                    BriefLocalization.text(en: "Energy and sleep", ru: "Энергия и сон"),
                ]
            case .creativity:
                [
                    BriefLocalization.text(en: "Music", ru: "Музыка"),
                    BriefLocalization.text(en: "Photo / video", ru: "Фото / видео"),
                    BriefLocalization.text(en: "Design", ru: "Дизайн"),
                    BriefLocalization.text(en: "Art", ru: "Искусство"),
                ]
            case .career:
                [
                    BriefLocalization.text(en: "Find a job", ru: "Найти работу"),
                    BriefLocalization.text(en: "Change fields", ru: "Сменить сферу"),
                    BriefLocalization.text(en: "Remote or freelance", ru: "Удаленка или фриланс"),
                    BriefLocalization.text(en: "Get promoted", ru: "Получить повышение"),
                ]
            case .itProduct:
                [
                    BriefLocalization.text(en: "Programming", ru: "Программирование"),
                    BriefLocalization.text(en: "AI / no-code", ru: "AI / no-code"),
                    BriefLocalization.text(en: "Product", ru: "Продукт"),
                    BriefLocalization.text(en: "Design in IT", ru: "Дизайн в IT"),
                ]
            case .productivity:
                [
                    BriefLocalization.text(en: "Discipline", ru: "Дисциплина"),
                    BriefLocalization.text(en: "Routine", ru: "Рутина"),
                    BriefLocalization.text(en: "Focus", ru: "Фокус"),
                    BriefLocalization.text(en: "Habits", ru: "Привычки"),
                ]
            }
        }

        var targetQuestion: String {
            switch self {
            case .money: BriefLocalization.text(en: "What amount?", ru: "Какая сумма?")
            case .content:
                BriefLocalization.text(
                    en: "What result do you want?", ru: "Какой результат ты хочешь?")
            case .business:
                BriefLocalization.text(
                    en: "What are you selling and to whom?", ru: "Что ты продаешь и кому?")
            case .learning:
                BriefLocalization.text(
                    en: "What result do you want?", ru: "Какой результат ты хочешь?")
            case .health:
                BriefLocalization.text(
                    en: "What is your current state and target?",
                    ru: "Какая текущая ситуация и цель?")
            case .creativity:
                BriefLocalization.text(
                    en: "What result do you want?", ru: "Какой результат ты хочешь?")
            case .career:
                BriefLocalization.text(
                    en: "What role and income do you want?", ru: "Какую роль и доход ты хочешь?")
            case .itProduct:
                BriefLocalization.text(
                    en: "What result do you want?", ru: "Какой результат ты хочешь?")
            case .productivity:
                BriefLocalization.text(
                    en: "What result would feel like progress?",
                    ru: "Какой результат будет ощущаться как прогресс?")
            }
        }

        var targetTip: String {
            switch self {
            case .money:
                BriefLocalization.text(
                    en: "Add a target number and time frame.", ru: "Добавь целевую сумму и срок.")
            case .content:
                BriefLocalization.text(
                    en: "Give Sofa a number when you can.", ru: "Укажи число, если можешь.")
            case .business:
                BriefLocalization.text(
                    en: "Niche, product, price, geography, and audience.",
                    ru: "Ниша, продукт, цена, география и аудитория.")
            case .learning:
                BriefLocalization.text(
                    en: "Give Sofa a measurable goal and time frame.",
                    ru: "Добавь измеримую цель и срок.")
            case .health:
                BriefLocalization.text(
                    en: "Add current numbers, desired result, deadline, and health limits.",
                    ru: "Добавь текущие числа, желаемый результат, срок и ограничения по здоровью.")
            case .creativity:
                BriefLocalization.text(
                    en: "Name the output, metric, or milestone.",
                    ru: "Назови результат, метрику или milestone.")
            case .career:
                BriefLocalization.text(
                    en: "Target role, format, salary, location, and time frame.",
                    ru: "Целевая роль, формат, зарплата, локация и срок.")
            case .itProduct:
                BriefLocalization.text(
                    en: "Role, project, milestone, or launch date.",
                    ru: "Роль, проект, milestone или дата запуска.")
            case .productivity:
                BriefLocalization.text(
                    en: "Give Sofa a measurable outcome and time frame.",
                    ru: "Добавь измеримый результат и срок.")
            }
        }

        var targetExamples: [String] {
            switch self {
            case .money:
                [
                    BriefLocalization.text(en: "pay off $5,000", ru: "погасить $5,000"),
                    BriefLocalization.text(
                        en: "save $2,000 for a laptop", ru: "накопить $2,000 на ноутбук"),
                ]
            case .content:
                [
                    BriefLocalization.text(
                        en: "10k followers or 20 qualified leads in 90 days",
                        ru: "10k подписчиков или 20 качественных лидов за 90 дней")
                ]
            case .business:
                [
                    BriefLocalization.text(
                        en: "$120 therapy sessions for founders in NYC",
                        ru: "сессии терапии за $120 для основателей в Нью-Йорке")
                ]
            case .learning:
                [
                    BriefLocalization.text(
                        en: "speak at B1 or pass IELTS", ru: "говорить на B1 или сдать IELTS")
                ]
            case .health:
                [
                    BriefLocalization.text(
                        en: "170 lb -> 155 lb, 2 workouts/week, knee pain",
                        ru: "170 lb -> 155 lb, 2 тренировки/неделю, боль в колене")
                ]
            case .creativity:
                [
                    BriefLocalization.text(
                        en: "12-piece portfolio or first $500 commission",
                        ru: "портфолио из 12 работ или первый заказ на $500")
                ]
            case .career:
                [
                    BriefLocalization.text(
                        en: "junior marketer, remote, $3k/month",
                        ru: "junior-маркетолог, удаленно, $3k/месяц")
                ]
            case .itProduct:
                [
                    BriefLocalization.text(
                        en: "junior frontend or MVP", ru: "junior frontend или MVP")
                ]
            case .productivity:
                [
                    BriefLocalization.text(
                        en: "focused work 90 min/day for 30 days",
                        ru: "90 минут фокусной работы в день 30 дней"
                    )
                ]
            }
        }

        var currentStateQuestion: String {
            switch self {
            case .money:
                BriefLocalization.text(
                    en: "What is your current money situation?",
                    ru: "Какая у тебя сейчас финансовая ситуация?")
            case .content:
                BriefLocalization.text(
                    en: "What do you have right now?", ru: "Что у тебя есть сейчас?")
            case .business:
                BriefLocalization.text(
                    en: "What are the current and target numbers?",
                    ru: "Какие текущие и целевые цифры?")
            case .learning:
                BriefLocalization.text(
                    en: "What is your current level and routine?",
                    ru: "Какой текущий уровень и режим?")
            case .health:
                BriefLocalization.text(
                    en: "What gets in the way most?", ru: "Что мешает больше всего?")
            case .creativity:
                BriefLocalization.text(
                    en: "What do you have right now?", ru: "Что у тебя есть сейчас?")
            case .career:
                BriefLocalization.text(
                    en: "What is your current experience and blocker?",
                    ru: "Какой текущий опыт и главный блокер?")
            case .itProduct:
                BriefLocalization.text(
                    en: "What is your current level and stack?", ru: "Какой текущий уровень и стек?"
                )
            case .productivity:
                BriefLocalization.text(
                    en: "Where does the day break down?", ru: "Где день чаще всего ломается?")
            }
        }

        var currentStateTip: String {
            switch self {
            case .money:
                BriefLocalization.text(
                    en: "Income, expenses, debt, savings, and stability matter.",
                    ru: "Важны доход, расходы, долги, сбережения и стабильность.")
            case .content:
                BriefLocalization.text(
                    en: "Audience size, cadence, offer, and blockers matter.",
                    ru: "Важны размер аудитории, частота, оффер и блокеры.")
            case .business:
                BriefLocalization.text(
                    en: "Current metrics, target metrics, budget, team, and bottleneck.",
                    ru: "Текущие метрики, целевые метрики, бюджет, команда и узкое место.")
            case .learning:
                BriefLocalization.text(
                    en: "Level, available time, materials, and weak spots.",
                    ru: "Уровень, доступное время, материалы и слабые места.")
            case .health:
                BriefLocalization.text(
                    en: "Time, energy, injuries, food, and schedule matter.",
                    ru: "Важны время, энергия, травмы, питание и расписание.")
            case .creativity:
                BriefLocalization.text(
                    en: "Skill, existing work, tools, audience, and available time.",
                    ru: "Навык, текущие работы, инструменты, аудитория и доступное время.")
            case .career:
                BriefLocalization.text(
                    en: "Role, skills, resume, portfolio, market, and constraints.",
                    ru: "Роль, навыки, резюме, портфолио, рынок и ограничения.")
            case .itProduct:
                BriefLocalization.text(
                    en: "Skills, tools, projects, blockers, and available time.",
                    ru: "Навыки, инструменты, проекты, блокеры и доступное время.")
            case .productivity:
                BriefLocalization.text(
                    en: "Failure point, energy, schedule, and distractions.",
                    ru: "Точка срыва, энергия, расписание и отвлечения.")
            }
        }

        var currentStateExamples: [String] {
            switch self {
            case .money:
                [
                    BriefLocalization.text(
                        en: "$3,200 income, $2,100 expenses, $8,000 debt, stable",
                        ru: "$3,200 доход, $2,100 расходы, $8,000 долг, стабильно")
                ]
            case .content:
                [
                    BriefLocalization.text(
                        en: "1,200 followers, 2 reels/week, no product yet, low reach",
                        ru: "1,200 подписчиков, 2 reels/неделю, продукта пока нет, низкий охват")
                ]
            case .business:
                [
                    BriefLocalization.text(
                        en: "15 leads/mo -> 40, 3 sales -> 10, $500 budget, weak follow-up",
                        ru: "15 лидов/мес -> 40, 3 продажи -> 10, бюджет $500, слабый follow-up")
                ]
            case .learning:
                [
                    BriefLocalization.text(
                        en: "A2, 25 min/day, grammar is weak, learn on commute",
                        ru: "A2, 25 мин/день, слабая грамматика, учусь в дороге")
                ]
            case .health:
                [
                    BriefLocalization.text(
                        en: "no time after work, knee pain, late dinners, low sleep",
                        ru: "нет времени после работы, болит колено, поздние ужины, мало сна")
                ]
            case .creativity:
                [
                    BriefLocalization.text(
                        en: "12 photos, basic editing, iPhone only, 4 hours/week",
                        ru: "12 фото, базовый монтаж, только iPhone, 4 часа/неделю")
                ]
            case .career:
                [
                    BriefLocalization.text(
                        en: "restaurant manager, 2 years, no resume, weak analytics, 5 h/week",
                        ru: "менеджер ресторана, 2 года, нет резюме, слабая аналитика, 5 ч/неделю")
                ]
            case .itProduct:
                [
                    BriefLocalization.text(
                        en: "HTML/CSS basics, no backend, evenings only, need portfolio",
                        ru: "база HTML/CSS, нет backend, только вечера, нужно портфолио")
                ]
            case .productivity:
                [
                    BriefLocalization.text(
                        en: "mornings are rushed, phone at night, low energy after work",
                        ru: "утром спешка, телефон ночью, мало энергии после работы")
                ]
            }
        }

        var preferencesTip: String {
            BriefLocalization.text(
                en: "Add limits, pace, budget, and anything Sofa should avoid.",
                ru: "Добавь ограничения, темп, бюджет и то, чего Sofa стоит избегать."
            )
        }

        var preferenceExamples: [String] {
            switch self {
            case .money, .business:
                [
                    BriefLocalization.text(
                        en: "evenings only, $0 budget, simple sales steps",
                        ru: "только вечерами, бюджет $0, простые шаги"),
                    BriefLocalization.text(
                        en: "gentle pace, free tools, avoid risky tactics",
                        ru: "мягкий темп, бесплатные инструменты, без рискованных тактик"),
                ]
            case .health:
                [
                    BriefLocalization.text(
                        en: "no gym, evenings only, knee-safe exercises",
                        ru: "без зала, только вечерами, упражнения без нагрузки на колено"),
                    BriefLocalization.text(
                        en: "simple meals, low impact, no strict diets",
                        ru: "простая еда, низкая нагрузка, без строгих диет"),
                ]
            case .learning, .itProduct:
                [
                    BriefLocalization.text(
                        en: "20 minutes a day, no paid courses, practice first",
                        ru: "20 минут в день, без платных курсов, сначала практика"),
                    BriefLocalization.text(
                        en: "evenings only, free tools, project-based learning",
                        ru: "только вечерами, бесплатные инструменты, обучение через проект"),
                ]
            case .career:
                [
                    BriefLocalization.text(
                        en: "remote only, 5 hours a week, no expensive courses",
                        ru: "только удаленка, 5 часов в неделю, без дорогих курсов"),
                    BriefLocalization.text(
                        en: "portfolio first, calm pace, avoid cold calls",
                        ru: "сначала портфолио, спокойный темп, без холодных звонков"),
                ]
            case .content:
                [
                    BriefLocalization.text(
                        en: "30 minutes a day, no paid ads, calm tone, simple content",
                        ru: "30 минут в день, без платной рекламы, спокойный тон, простой контент"),
                    BriefLocalization.text(
                        en: "evenings only, $0 budget, gentle pace, simple steps",
                        ru: "только вечерами, бюджет $0, мягкий темп, простые шаги"),
                ]
            case .creativity:
                [
                    BriefLocalization.text(
                        en: "weekends only, no expensive gear, portfolio first",
                        ru: "только по выходным, без дорогого оборудования, сначала портфолио"),
                    BriefLocalization.text(
                        en: "simple publishing, gentle feedback, free tools",
                        ru: "простая публикация, мягкая обратная связь, бесплатные инструменты"),
                ]
            case .productivity:
                [
                    BriefLocalization.text(
                        en: "flexible schedule, small steps, no morning routine",
                        ru: "гибкое расписание, маленькие шаги, без утренней рутины"),
                    BriefLocalization.text(
                        en: "evenings only, no strict tracking, low pressure",
                        ru: "только вечерами, без строгого трекинга, без давления"),
                ]
            }
        }
    }

    // MARK: - Timeframe

    enum Timeframe: Int, CaseIterable, Equatable {
        case month1, month3, month6

        var name: String {
            switch self {
            case .month1: String(format: String(localized: "monthsPluralFormat"), 1)
            case .month3: String(format: String(localized: "monthsPluralFormat"), 3)
            case .month6: String(format: String(localized: "monthsPluralFormat"), 6)
            }
        }

        var generatorValue: String {
            switch self {
            case .month1: "1_month"
            case .month3: "3_months"
            case .month6: "6_months"
            }
        }
    }
}

extension Project.Plan {

    // MARK: - Week

    struct Week: Identifiable, Hashable {
        let id: UUID
        let number: Int
        var steps: [Step]
        var isCompleted: Bool {
            steps.allSatisfy(\.isCompleted)
        }
    }

    // MARK: - Step

    struct Step: Identifiable, Hashable {
        let id: UUID
        let title: String
        let number: Int
        var isCompleted: Bool
    }

    // MARK: - Difficulty

    enum Difficulty: Int, Hashable, CaseIterable {
        case easy, average, difficult

        var name: String {
            switch self {
            case .easy: String(localized: "easy")
            case .average: String(localized: "average")
            case .difficult: String(localized: "difficult")
            }
        }

        var color: ColorResource {
            switch self {
            case .easy: .green34C759
            case .average: .yellowFFCC00
            case .difficult: .redFF3B30
            }
        }
    }

    // MARK: - Chat

    struct Chat: Identifiable, Hashable {
        let id: UUID
        var conversation: Conversation?
        var messages: [Message] = []
    }
}

extension Project.Plan.Chat {

    // MARK: - Message

    struct Message: Identifiable, Hashable {
        let id: UUID
        let itemID: String?
        let text: String
        let context: String?
        let isFromUser: Bool
        let isFailed: Bool
        let createdAt: Date

        func sent(itemID: String?) -> Project.Plan.Chat.Message {
            Project.Plan.Chat.Message(
                id: id,
                itemID: itemID,
                text: text,
                context: context,
                isFromUser: isFromUser,
                isFailed: isFailed,
                createdAt: createdAt
            )
        }

        func fail() -> Project.Plan.Chat.Message {
            Project.Plan.Chat.Message(
                id: id,
                itemID: itemID,
                text: text,
                context: context,
                isFromUser: isFromUser,
                isFailed: true,
                createdAt: createdAt
            )
        }
    }

    struct Conversation: Identifiable, Hashable {
        let id: String
        let context: String
        let isDirty: Bool
    }
}

// MARK: - Mocks

extension Project {
    static let mock = Project(
        id: UUID(),
        brief: Brief(
            id: UUID(),
            category: .business,
            focus: "Clients and leads",
            target: "$120 therapy sessions for founders in NYC",
            currentState: "15 leads/mo -> 40, 3 sales -> 10, $500 budget",
            preferences: "30 minutes a day, calm tone, simple steps",
            timeframe: .month3
        ),
        summary: "Roadmap to build and launch an iOS app.",
        plans: [
            Plan(
                id: UUID(),
                title: "Design & Branding",
                emoji: "🎨",
                firstResults: "3–4 weeks",
                budget: 1000,
                result: "App identity, logo, and UI components ready",
                difficulty: .easy,
                weeks: [
                    .init(
                        id: UUID(),
                        number: 1,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Create color palette and typography",
                                number: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Design app icon",
                                number: 2,
                                isCompleted: false
                            ),
                        ]
                    ),
                    .init(
                        id: UUID(),
                        number: 2,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Build UI kit in Figma",
                                number: 1,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Design splash screen",
                                number: 2,
                                isCompleted: false
                            ),
                        ]
                    ),
                ],
                isFavorite: false,
                createdAt: .now
            ),
            Plan(
                id: UUID(),
                title: "Core App Development",
                emoji: "💻",
                firstResults: "2–3 weeks",
                budget: 2000,
                result: "Functional MVP with core features",
                difficulty: .average,
                weeks: [
                    .init(
                        id: UUID(),
                        number: 1,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Implement SwiftData models",
                                number: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Add main UI modules",
                                number: 2,
                                isCompleted: true
                            ),
                        ]
                    ),
                    .init(
                        id: UUID(),
                        number: 2,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Integrate iCloud sync",
                                number: 0,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Add notifications and background refresh",
                                number: 1,
                                isCompleted: false
                            ),
                        ]
                    ),
                ],
                isFavorite: true,
                createdAt: .now
            ),
            Plan(
                id: UUID(),
                title: "App Store Launch",
                emoji: "🚀",
                firstResults: "2–4 weeks",
                budget: 5000,
                result: "Live app available on App Store",
                difficulty: .difficult,
                weeks: [
                    .init(
                        id: UUID(),
                        number: 1,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Write App Store description",
                                number: 1,
                                isCompleted: true
                            ),
                            .init(
                                id: UUID(),
                                title: "Prepare keywords and metadata",
                                number: 2,
                                isCompleted: false
                            ),
                        ]
                    ),
                    .init(
                        id: UUID(),
                        number: 2,
                        steps: [
                            .init(
                                id: UUID(),
                                title: "Prepare screenshots and preview video",
                                number: 1,
                                isCompleted: false
                            ),
                            .init(
                                id: UUID(),
                                title: "Submit build and pass review",
                                number: 2,
                                isCompleted: false
                            ),
                        ]
                    ),
                ],
                isFavorite: true,
                createdAt: .now
            ),
        ],
        hasLifetimeAccess: false,
        createdAt: Date().addingTimeInterval(-86400 * 10),
        updatedAt: Date()
    )
}
